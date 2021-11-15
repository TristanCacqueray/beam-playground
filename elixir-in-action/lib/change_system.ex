defmodule Change.System do
  def start_link do
    Supervisor.start_link(
      [Change.Cache, Change.Database],
      strategy: :one_for_one
    )
  end
end
