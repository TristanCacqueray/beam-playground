defmodule ChangeCacheTest do
  use ExUnit.Case

  setup_all do
    {:ok, todo_system_pid} = Change.System.start_link()
    {:ok, todo_system_pid: todo_system_pid}
  end

  test "server_process" do
    bob_pid = Change.Cache.server_process(%{name: "bob"})

    assert bob_pid != Change.Cache.server_process(%{name: "alice"})
    assert bob_pid == Change.Cache.server_process(%{name: "bob"})
  end
end
