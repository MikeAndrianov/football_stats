defmodule FootballStats.FetchDataWorker do
  use GenServer

  alias FootballStats.{Match, Repo}

  @request_interval 30_000

  def start_link(args) do
    provider = args.provider

    GenServer.start_link(__MODULE__, args, name: provider)
  end

  def init(state) do
    schedule_stats_fetching()

    {:ok, state}
  end

  def handle_info(:fetch_stats, state) do
    {:ok, matches, args} = apply(state.provider, :fetch_matches, [state])

    Repo.insert_all(Match, matches, on_conflict: :nothing)

    schedule_stats_fetching()
    {:noreply, Map.put(state, :last_checked_at, args[:last_checked_at])}
  end

  defp schedule_stats_fetching() do
    Process.send_after(self(), :fetch_stats, @request_interval)
  end
end
