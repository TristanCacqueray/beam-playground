defmodule ChangeServer do
  # Client side function
  def start do
    spawn(fn -> loop(Change.new()) end)
  end

  def add_event(change_server, new_event) do
    send(change_server, {:add_event, new_event})
  end

  def get_events(change_server) do
    send(change_server, {:events, self()})

    receive do
      {:events, events} -> events
    after
      5000 -> {:error, :timeout}
    end
  end

  # Server implementation
  defp loop(change) do
    new_change =
      receive do
        message -> process_message(change, message)
      end

    loop(new_change)
  end

  defp process_message(change, {:add_event, new_event}) do
    Change.add_event(change, new_event)
  end

  defp process_message(change, {:events, caller}) do
    send(caller, {:events, Change.events(change)})
    change
  end

  defp process_message(change, _), do: change
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
