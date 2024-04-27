defmodule Battler.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:battler, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Battler.PubSub},
      {Finch, name: Battler.Finch},
      {Registry, keys: :unique, name: Battler.BattlerRegistry},
      BattlerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Battler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BattlerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
