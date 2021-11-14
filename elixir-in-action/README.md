# Elixir in Action

This project contains a change server, inspired by the todo server sample from the book.

# Standalone server

```elixir
$ iex lib/change_server.ex
> {:ok, s} = GenServer.start_link(ChangeServer, nil)
{:ok, #PID<0.125.0>}
> ChangeServer.add_event(s, %{type: :pr, nr: 42})
:ok
> ChangeServer.add_event(s, %{event: "recheck"})
:ok
> ChangeServer.get_events(s)
%{
  1 => %{date: ~U[2021-11-14 20:13:26.215471Z], id: 1, nr: 42, type: :pr},
  2 => %{date: ~U[2021-11-14 20:13:29.967250Z], event: "recheck", id: 2}
}
```

# REPL

* Browse a module: `exports ChangeServer`
* Reload a module: `r ChangeServer`
