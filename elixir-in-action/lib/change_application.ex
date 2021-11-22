defmodule Change.Application do
  use Application

  def start(_, _) do
    Change.System.start_link()
  end
end
