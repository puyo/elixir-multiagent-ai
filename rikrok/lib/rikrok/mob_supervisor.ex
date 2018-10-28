defmodule Rikrok.MobSupervisor do
  use DynamicSupervisor

  # --------------------------------------------------
  # client

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(%struct{} = m) do
    spec = {struct, [m]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # --------------------------------------------------
  # server

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
