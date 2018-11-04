defmodule FootballStats.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias FootballStats.DataProviders.{Matchbeam, FastBall}

  @data_providers [Matchbeam, FastBall]

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [FootballStats.Repo | fetch_workers]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FootballStats.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp fetch_workers do
    @data_providers
    |> Enum.map(fn data_provider ->
      Supervisor.child_spec(
        {FootballStats.FetchDataWorker, %{provider: data_provider}},
        id: data_provider,
        restart: :transient
      )
    end)
  end
end
