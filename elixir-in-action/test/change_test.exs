defmodule ChangeTest do
  use ExUnit.Case, async: true

  test "empty list" do
    assert Change.events(Change.new()) == []
  end

  test "events" do
    change = Change.new([%{comment: "recheck"}])

    assert Change.events(change) |> length == 1
  end

  test "add_event" do
    change = Change.new([%{comment: "recheck"}]) |> Change.add_event(%{comment: "merge"})

    assert Change.events(change) |> length == 2
  end
end
