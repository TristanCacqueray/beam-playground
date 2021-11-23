# Data structure
defmodule Change do
  defstruct auto_id: 1, events: []

  def new(events \\ []) do
    Enum.reduce(
      events,
      %Change{},
      &add_event(&2, &1)
    )
  end

  def add_event(change, event) do
    event = Map.put(event, :id, change.auto_id) |> Map.put(:date, DateTime.utc_now())
    new_events = [event | change.events]
    %Change{change | events: new_events, auto_id: change.auto_id + 1}
  end

  def events(change) do
    change.events
  end
end
