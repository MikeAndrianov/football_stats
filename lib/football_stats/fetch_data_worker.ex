defmodule FootballStats.FetchDataWorker do
  use GenServer
  import Ecto.Query

  alias FootballStats.{Match, Repo}

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
    matches = matches_stats() |> transform_records

    Repo.insert_all(Match, matches)

    schedule_stats_fetching()
    {:noreply, state ++ matches}
  end

  defp matches_stats do
    (Application.get_env(:football_stats, :forza_api) <> "/feed/matchbeam")
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("matches")
  end

  defp schedule_stats_fetching do
    Process.send_after(self(), :fetch_stats, @request_interval)
  end

  defp transform_records(matches) do
    matches
    |> Enum.map(&transform_record/1)
  end

  # TODO: only for matchbeam
  defp transform_record(match) do
    match
    |> format_record
    |> transform_time
    |> add_provider
  end

  defp format_record(%{"teams" => teams, "created_at" => created_at}) do
    [home_team, away_team] = String.split(teams, " - ")

    %{
      home_team: home_team,
      away_team: away_team,
      created_at: created_at
    }
  end

  defp transform_time(%{created_at: unix_time} = match) do
    %{match | created_at: DateTime.from_unix!(unix_time)}
  end

  defp add_provider(match), do: Map.put(match, :provider, "matchbeam")
end
