defmodule Rikrok.Person do
  @moduledoc false

  # --------------------------------------------------
  # struct

  @behaviour Rikrok.Mob

  defstruct name: nil, x: 0, y: 0, inventory: [], colour: 0

  @impl true
  def glyph(t) do
    {"@", t.colour}
  end

  # --------------------------------------------------
  # client

  def start_link([person]) do
    GenServer.start_link(__MODULE__, [person])
  end

  def name(pid), do: GenServer.call(pid, :name)

  # --------------------------------------------------
  # server

  use GenServer

  @impl true
  def init([person]) do
    #IO.puts "Person: init #{inspect person}"
    Process.send_after(self(), :update, 20)
    {:ok, person}
  end

  @impl true
  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  @impl true
  def handle_info(:update, state) do
    new_state = update(state)
    Process.send_after(self(), :update, 200)
    {:noreply, new_state}
  end

  def update(state) do
    #IO.inspect "Updating #{state.name}"
    dx = :rand.uniform(3) - 2
    dy = :rand.uniform(3) - 2
    GenServer.call(Rikrok.World, {:move_mob, state, dx, dy})
  end
end
