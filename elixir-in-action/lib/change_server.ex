defmodule Change.Server do
  use GenServer, restart: :temporary

  def add_event(change_server, new_event) do
    GenServer.cast(change_server, {:add_event, new_event})
  end

  def get_events(change_server) do
    GenServer.call(change_server, {:events})
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Change.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  # After two days of inactivity, remove a PR
  @expiry_idle_timeout :timer.hours(2 * 24)

  @impl true
  def init(name) do
    IO.puts("Starting change server for #{inspect(name)}")
    {:ok, {name, Change.Database.get(name) || Change.new()}, @expiry_idle_timeout}
  end

  @impl true
  def handle_cast({:add_event, new_event}, {name, change}) do
    new_change = Change.add_event(change, new_event)
    Change.Database.store(name, new_change)
    {:noreply, {name, new_change}, @expiry_idle_timeout}
  end

  @impl true
  def handle_call({:events}, _from, {name, change}) do
    {:reply, Change.events(change), {name, change}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, {name, change}) do
    IO.puts("Stopping change server for #{inspect(name)}")
    {:stop, :normal, {name, change}}
  end
end
