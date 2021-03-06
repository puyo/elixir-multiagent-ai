defmodule Rikrok.Person do
  @moduledoc false

  # --------------------------------------------------
  # struct

  @behaviour Rikrok.Mob

  defstruct name: nil, x: 0, y: 0, inventory: [], colour: 0, tipped: false

  @impl true
  def glyph(t) do
    {"@", if t.tipped do 0x00ff00 else t.colour end}
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
    dx = Enum.random(-1..1)
    dy = Enum.random(-1..1)
    GenServer.call(Rikrok.World, {:move_mob, state, dx, dy})
  end
end
