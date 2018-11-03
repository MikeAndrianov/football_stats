defmodule FootballStats.Repo.Migrations.CreateMatch do
  use Ecto.Migration

  def change do
    create table(:match) do
      add :home_team, :string, null: false
      add :away_team, :string, null: false
      add :created_at, :utc_datetime, null: false
      add :provider, :string, null: false
    end
  end
end
