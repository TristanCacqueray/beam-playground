# Elixir in Action

This project contains a change server, inspired by the todo server sample from the book.

Start the REPL with:

```
$ mix test
$ iex -S mix
```

# Persistent Cache server

```elixir
> {:ok, cache} = Change.Cache.start()
{:ok, #PID<0.212.0>}
> s = Change.Cache.server_process(cache, %{pr: 42})
#PID<0.214.0>
> Change.Server.add_event(s, %{event: "recheck"})
:ok
> Change.Server.get_events(s)
[%{date: ~U[2021-11-14 23:34:06.496921Z], event: "recheck", id: 1}]
```

# Bench 100k changes

```elixir
> {:ok, cache} = Change.Cache.start()
{:ok, #PID<0.138.0>}
> :timer.tc(fn -> Enum.each(1..100_000, fn index -> Change.Cache.server_process(cache, %{pr: index}) end) end)
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
