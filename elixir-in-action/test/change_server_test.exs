defmodule ChangeServerTest do
  use ExUnit.Case, async: true

  test "add_events" do
    Change.System.start_link()

    change_pid = Change.Cache.server_process(%{pr: 1})
    assert([] == Change.Server.get_events(change_pid))

    Change.Server.add_event(change_pid, %{comment: "hello"})
    assert(1 == Change.Server.get_events(change_pid) |> length)
  end
end
