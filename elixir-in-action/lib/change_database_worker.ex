defmodule Change.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    IO.puts("Starting database worker #{worker_id}")
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  def store(worker_pid, key, data) do
    GenServer.cast(via_tuple(worker_pid), {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(via_tuple(worker_pid), {:get, key})
  end

  defp via_tuple(worker_id) do
    Change.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, map) do
    name = Map.keys(map)
    |> Enum.map(fn key -> "#{key},#{map[key]}" end)
    |> Enum.join(",")
    Path.join(db_folder, name)
  end
end
