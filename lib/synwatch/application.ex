defmodule Synwatch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SynwatchWeb.Telemetry,
      Synwatch.Repo,
      {Finch, name: SynwatchFinch},
      {DNSCluster, query: Application.get_env(:synwatch, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Synwatch.PubSub},
      # Start a worker by calling: Synwatch.Worker.start_link(arg)
      # {Synwatch.Worker, arg},
      # Start to serve requests, typically the last entry
      SynwatchWeb.Endpoint,
      Synwatch.Vault
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Synwatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SynwatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
