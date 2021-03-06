defmodule FootballStats.Match do
  use Ecto.Schema

  schema "match" do
    field(:home_team)
    field(:away_team)
    field(:provider)
    field(:created_at, :utc_datetime)
  end
end
