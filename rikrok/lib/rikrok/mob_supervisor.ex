defmodule Rikrok.MobSupervisor do
  use DynamicSupervisor

  # --------------------------------------------------
  # client

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(%Rikrok.Person{} = m) do
    #IO.puts "MobSupervisor: start_child #{inspect m}"
    spec = {Rikrok.Person, [m]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # --------------------------------------------------
  # server

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
