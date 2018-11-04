defmodule FootballStats.DataProvider do
  @doc "Fetches matches data from the API"
  @callback fetch_matches() :: {:ok, list, map}
end
