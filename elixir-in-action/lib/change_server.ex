defmodule Change.Server do
  use Agent, restart: :temporary

  def start_link(name) do
    Agent.start_link(
      fn -> {name, Change.Database.get(name) || Change.new()} end,
      name: via_tuple(name)
    )
  end

  defp via_tuple(name) do
    Change.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  def add_event(change_server, new_event) do
    Agent.cast(change_server, fn {name, change} ->
      new_change = Change.add_event(change, new_event)
      Change.Database.store(name, new_change)
      {name, new_change}
    end)
  end

  def get_events(change_server) do
    Agent.get(change_server, fn {_name, change} -> Change.events(change) end)
  end
end

# Data structure
defmodule Change do
  defstruct auto_id: 1, events: %{}

  def new(events \\ []) do
    Enum.reduce(
      events,
      %Change{},
      &add_event(&2, &1)
    )
  end

  def add_event(change, event) do
    event = Map.put(event, :id, change.auto_id) |> Map.put(:date, DateTime.utc_now())
    new_events = Map.put(change.events, change.auto_id, event)
    %Change{change | events: new_events, auto_id: change.auto_id + 1}
  end

  def events(change) do
    change.events
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_event(change, %{} = new_event) do
    update_event(change, new_event.id, fn _ -> new_event end)
  end

  def update_event(change, event_id, updater_fun) do
    case Map.fetch(change.events, event_id) do
      :error ->
        change

      {:ok, old_event} ->
        new_event = updater_fun.(old_event)
        new_events = Map.put(change.events, new_event.id, new_event)
        %Change{change | events: new_events}
    end
  end

  def delete_event(change, event_id) do
    %Change{change | events: Map.delete(change.events, event_id)}
  end
end
