# FootballStats

## Installation

Before running please edit `/config/config.exs` db credentials:

```elixir
config :football_stats, FootballStats.Repo,
  database: "forza_football_stats_development",
  username: "your username",
  password: "your password",
  ...
```

and then run
```elixir
mix ecto.create
mix ecto.migrate
mix run --no-halt

```
