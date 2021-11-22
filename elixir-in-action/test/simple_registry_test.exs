defmodule TestSR do
  use ExUnit.Case, async: false

  test "sr_gen_server" do
    SimpleRegistry.start_link()
    assert SimpleRegistry.register("foo") == :ok
    assert SimpleRegistry.register("foo") == :error
    assert SimpleRegistry.whereis("foo") == self()
    assert SimpleRegistry.whereis("bar") == nil

    {:ok, pid} = Agent.start_link(fn -> SimpleRegistry.register("bar") end)
    assert SimpleRegistry.whereis("bar") == pid
    Agent.stop(pid)
    Process.sleep(100)
    assert SimpleRegistry.whereis("bar") == nil
  end

  test "sr_ets" do
    SimpleRegistryETS.start_link()
    assert SimpleRegistryETS.register("foo") == :ok
    assert SimpleRegistryETS.register("foo") == :error
    assert SimpleRegistryETS.whereis("foo") == self()
    assert SimpleRegistryETS.whereis("bar") == nil

    {:ok, pid} = Agent.start_link(fn -> SimpleRegistryETS.register("bar") end)
    assert SimpleRegistryETS.whereis("bar") == pid
    Agent.stop(pid)
    Process.sleep(100)
    assert SimpleRegistryETS.whereis("bar") == nil
  end
end
