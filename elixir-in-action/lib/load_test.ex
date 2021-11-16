# Original: https://github.com/sasa1977/elixir-in-action/blob/master/code_samples/ch07/todo_cache/lib/load_test.ex
#
# Start from command line with:
#   elixir --erl "+P 2000000" -S mix run -e LoadTest.run
#
# Note: the +P 2000000 sets maximum number of processes to 2 millions
defmodule LoadTest do
  @total_processes 1_000_000
  @interval_size 100_000

  def run do
    {:ok, _cache} = Change.System.start_link()

    interval_count = round(@total_processes / @interval_size)
    Enum.each(0..(interval_count - 1), &run_interval(make_interval(&1)))
  end

  defp make_interval(n) do
    start = n * @interval_size
    start..(start + @interval_size - 1)
  end

  defp run_interval(interval) do
    {time, _} =
      :timer.tc(fn ->
        interval
        |> Enum.each(&Change.Cache.server_process(%{pr: &1}))
      end)

    IO.puts("#{inspect(interval)}: average put #{time / @interval_size} μs")

    {time, _} =
      :timer.tc(fn ->
        interval
        |> Enum.each(&Change.Cache.server_process(%{pr: &1}))
      end)

    IO.puts("#{inspect(interval)}: average get #{time / @interval_size} μs\n")
  end
end

defmodule Mix.Tasks.Load do
  @moduledoc "The load mix task: `mix help load`"
  use Mix.Task

  @shortdoc "Run the LoadTest."
  def run(_) do
    LoadTest.run()
  end
end
