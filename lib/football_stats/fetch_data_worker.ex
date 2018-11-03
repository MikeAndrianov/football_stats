defmodule FootballStats.FetchDataWorker do
  use GenServer

  # @request_interval 30_000
  @request_interval 3_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    schedule_stats_fetching()

    {:ok, state}
  end

  def handle_info(:fetch_stats, state) do
    matches = matches_stats()
    IO.puts(Enum.count(state))

    schedule_stats_fetching()
    {:noreply, state ++ matches}
  end

  defp matches_stats do
    Application.get_env(:football_stats, :forza_api) <> "/feed/matchbeam"
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("matches")
  end

  defp schedule_stats_fetching do
    Process.send_after(self(), :fetch_stats, @request_interval)
  end
end
