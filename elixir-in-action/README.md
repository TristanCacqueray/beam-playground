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
> {:ok, cache} = Change.Cache.start_link(nil)
{:ok, #PID<0.138.0>}
> :timer.tc(fn -> Enum.each(1..100_000, fn index -> Change.Cache.server_process(%{pr: index}) end) end)
{1924243, :ok}
> IO.puts("Elapsed #{1924243 / 1_000_000} sec")
Elapsed 1.924243 sec
> :erlang.system_info(:process_count)
100061
```

# REPL

* Browse a module: `exports ChangeServer`
* Reload a module: `r ChangeServer`
* Reload all modules: `recompile`
