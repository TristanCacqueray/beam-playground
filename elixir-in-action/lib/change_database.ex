defmodule Change.Database do
  @db_settings Application.fetch_env!(:eia, :database)
  @pool_size Keyword.fetch!(@db_settings, :pool_size)
  @db_folder Keyword.fetch!(@db_settings, :folder)

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Change.DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Change.DatabaseWorker.store(worker_pid, key, data) end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Change.DatabaseWorker.get(worker_pid, key) end
    )
  end
end
