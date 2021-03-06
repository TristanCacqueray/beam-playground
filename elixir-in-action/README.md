# Elixir in Action

This project contains a change server, inspired by the todo server sample from the book.

Start the REPL with:

```
$ mix test
$ iex -S mix
```

# Persistent Cache server

```elixir
> {:ok, changes} = Change.System.start_link()
Starting database worker 1
Starting database worker 2
Starting database worker 3
Starting to-do cache.
{:ok, #PID<0.212.0>}
> s = Change.Cache.server_process(%{pr: 42})
#PID<0.214.0>
> Change.Server.add_event(s, %{event: "recheck"})
:ok
> Change.Server.get_events(s)
[%{date: ~U[2021-11-14 23:34:06.496921Z], event: "recheck", id: 1}]

> Process.exit(s, :kill)
true
> s = Change.Cache.server_process(%{pr: 42})
#PID<0.155.0>
> Change.Server.get_events(s)
[%{date: ~U[2021-11-14 23:34:06.496921Z], event: "recheck", id: 1}]

> GenServer.stop(Change.ProcessRegistry.via_tuple({Change.DatabaseWorker, 1}))
:ok
Starting database worker 1
> IO.puts("Worker automatically restart")
```

# Bench 100k changes

```elixir
> {:ok, cache} = Change.Cache.start_link()
{:ok, #PID<0.138.0>}
> :timer.tc(fn -> Enum.each(1..100_000, fn index -> Change.Cache.server_process(%{pr: index}) end) end)
{1924243, :ok}
> IO.puts("Elapsed #{1924243 / 1_000_000} sec")
Elapsed 1.924243 sec
> :erlang.system_info(:process_count)
100061
```

Run load test with: `mix load`

# Bench 20 millions operations

```
$ mix run -e "Bench.run(KeyValue)"
   510_972 operations/sec

$ mix run -e "Bench.run(KeyValueEts)"
 2_815_343 operations/sec

$ mix run -e "Bench.run(KeyValue, concurrency: 1_000)"
   525_927 operations/sec

$ mix run -e "Bench.run(KeyValueEts, concurrency: 1_000)"
16_639_738 operations/sec
```

# Bench http cowboy

```
$ wrk -t4 -c20 -d30s --latency -s wrk.lua http://localhost:5454
Running 30s test @ http://localhost:5454
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.79ms    2.54ms  76.58ms   96.72%
    Req/Sec     3.22k     0.91k    5.96k    72.17%
  Latency Distribution
     50%    1.42ms
     75%    2.06ms
     90%    2.85ms
     99%    8.39ms
  384108 requests in 30.05s, 454.98MB read
Requests/sec:  12783.82
Transfer/sec:     15.14MB
```

# [Application](https://hexdocs.pm/elixir/1.12/Application.html)

```elixir
> Application.started_applications()
[
  {:eia, 'eia', '0.1.0'},
  {:logger, 'logger', '1.12.1'},
  {:mix, 'mix', '1.12.1'},
  {:iex, 'iex', '1.12.1'},
  {:elixir, 'elixir', '1.12.1'},
  {:compiler, 'ERTS  CXC 138 10', '8.0.1'},
  {:stdlib, 'ERTS  CXC 138 10', '3.15.1'},
  {:kernel, 'ERTS  CXC 138 10', '8.0.1'}
]
```

# [System](https://hexdocs.pm/elixir/System.html)

```elixir
# Quit
> System.stop
```

System observer:

```elixir
> :observer.start
```

# Process

* Check a process is alive: `Process.alive?(pid)`
* Kill a process: `Process.exit(pid, :kill)`

# REPL

* Show info: `i Enum`
* Browse a module: `exports Enum`
* Show help: `h Enum.sum`

* Compile a module: `c "./lib/change_server.ex"`

* Reload a module: `r Change.Server`
* Reload all modules: `recompile`

* Preserve history: `alias iex='iex --erl "-kernel shell_history enabled"'`
* Auto load module by adding to `.iex.exs`: `alias Change.Cache`

# Debug

* And breakpoint in code with [IEX.pry/0](https://hexdocs.pm/iex/IEx.html#pry/0): `require IEx; IEx.pry()` or set remote breakpoint with [`IEx.break!/4`](https://hexdocs.pm/iex/IEx.html#break!/4)
* Start the test with debugger: `iex -S mix test --trace`

# Remote

* Start named session: `iex --sname local`
* Attach to a named session: `iex --sname remote --remsh local@localhost`
