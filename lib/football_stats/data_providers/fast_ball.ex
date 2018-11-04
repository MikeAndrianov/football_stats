defmodule FootballStats.DataProviders.FastBall do
  @behaviour FootballStats.DataProvider

  def fetch_matches(state) do
    [persisted_match | matches] =
      Application.get_env(:football_stats, __MODULE__)[:api_url]
      |> HTTPoison.get!([], query_params(state))
      |> Map.get(:body)
      |> Jason.decode!()
      |> Map.get("matches")

    {:ok, transform_records(matches), %{last_checked_at: last_checked_at(matches)}}
  end

  def query_params(%{last_checked_at: last_checked_at}),
    do: [params: %{last_checked_at: last_checked_at}]

  def query_params(_state), do: []

  defp transform_records(matches) do
    matches
    |> Enum.map(&transform_record/1)
  end

  defp last_checked_at(matches), do: Enum.max(matches, & &1.created_at) |> Map.get("created_at")

  defp transform_record(match) do
    match
    |> convert_keys_to_atom
    |> transform_time
    |> add_provider
  end

  defp convert_keys_to_atom(match), do: match |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

  defp transform_time(%{created_at: unix_time} = match) do
    %{match | created_at: DateTime.from_unix!(unix_time)}
  end

  defp add_provider(match), do: Map.put(match, :provider, "fast_ball")
end
