defmodule Rikrok.Hunter do
  @moduledoc false

  # --------------------------------------------------
  # struct

  @behaviour Rikrok.Mob

  defstruct name: nil, x: 0, y: 0, inventory: [], colour: 0, tipped: false

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
    {:ok, area} = GenServer.call(Rikrok.World, {:look, state})

    target =
      area
      |> Rikrok.Matrix.mobs()
      |> Enum.reject(fn m -> m.tipped end)
      |> Enum.reject(fn m -> m == state end)
      |> Enum.sort_by(fn m -> Rikrok.Mob.dist_squared(m, state) end)
      |> List.first

    if is_nil(target) do
      dx = Enum.random(-1..1)
      dy = Enum.random(-1..1)
      GenServer.call(Rikrok.World, {:move_mob, state, dx, dy})
    else
      dx = target.x - state.x
      dy = target.y - state.y
      if (dx in -1..1) && (dy in -1..1) do
        GenServer.call(Rikrok.World, {:tag, state, target})
        state
      else
        ndx = normalize(dx)
        ndy = normalize(dy)
        new_state = GenServer.call(Rikrok.World, {:move_mob, state, ndx, ndy})
        new_state
      end
    end
  end

  defp normalize(0), do: 0
  defp normalize(v), do: div(v, abs(v))
end
