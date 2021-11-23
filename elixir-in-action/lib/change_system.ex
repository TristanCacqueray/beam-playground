defmodule Change.System do
  def start_link do
    Supervisor.start_link(
      [
        Change.Metrics,
        Change.ProcessRegistry,
        Change.Database,
        Change.Cache,
        Change.Web
      ],
      strategy: :one_for_one
    )
  end
end
