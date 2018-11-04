defmodule FootballStats.DataProviders.Matchbeam do
  @behaviour FootballStats.DataProvider

  def fetch_matches(state) do
    matches =
      Application.get_env(:football_stats, __MODULE__)[:api_url]
      |> HTTPoison.get!()
      |> Map.get(:body)
      |> Jason.decode!()
      |> Map.get("matches")
      |> transform_records

    {:ok, matches, %{}}
  end

  defp transform_records(matches) do
    matches
    |> Enum.map(&transform_record/1)
  end

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
