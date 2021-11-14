defmodule ChangeServerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, change_server} = GenServer.start(Change.Server, nil)
    on_exit(fn -> GenServer.stop(change_server) end)
    {:ok, change_server: change_server}
  end

  test "add_events", context do
    assert([] == Change.Server.get_events(context[:change_server]))

    Change.Server.add_event(context[:change_server], %{type: :pr})
    assert(1 == Change.Server.get_events(context[:change_server]) |> length)
  end
end
