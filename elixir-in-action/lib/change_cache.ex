defmodule Change.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, change_name) do
    GenServer.call(cache_pid, {:server_process, change_name})
  end

  @impl GenServer
  def init(_) do
    Change.Database.start()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, change_name}, _, change_servers) do
    case Map.fetch(change_servers, change_name) do
      {:ok, change_server} ->
        {:reply, change_server, change_servers}

      :error ->
        {:ok, new_server} = GenServer.start(Change.Server, change_name)

        {
          :reply,
          new_server,
          Map.put(change_servers, change_name, new_server)
        }
    end
  end
end
