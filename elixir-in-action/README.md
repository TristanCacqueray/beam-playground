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

# [System](https://hexdocs.pm/elixir/System.html)

```elixir
# Quit
> System.stop
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
