defmodule Change.System do
  def start_link do
    Supervisor.start_link(
      [
        Change.ProcessRegistry,
        Change.Database,
        Change.Cache
      ],
      strategy: :one_for_one
    )
  end
end
