defmodule ChangeCacheTest do
  use ExUnit.Case

  test "server_process" do
    bob_pid = Change.Cache.server_process(%{name: "bob"})

    assert bob_pid != Change.Cache.server_process(%{name: "alice"})
    assert bob_pid == Change.Cache.server_process(%{name: "bob"})
  end
end
