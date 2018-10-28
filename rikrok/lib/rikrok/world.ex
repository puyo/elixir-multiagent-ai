defmodule Rikrok.World do
  @moduledoc false

  use GenServer

  alias Rikrok.{Ground, Wall, Person}

  @world %{
    layout: """
    ................................................................................
    ................................................................................
    .....#####......................................................................
    .....#..........................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    #####...........................................................................
    ..@.....*.......................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ............######################################################..............
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ................................................................................
    ................................................................................
    ........@.......................................................................
    ................................................................................
    ................................................................................
    ........@.......................................................................
    ................................................................................
    """,
    key: %{
      "." => %Ground{},
      "#" => %Wall{},
      "@" => %Ground{mob: %Person{name: "Greg", colour: 0x0080FF}},
      "*" => %Ground{mob: %Person{name: "Ruby", colour: 0xFF0000}}
    }
  }

  # --------------------------------------------------
  # client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # --------------------------------------------------
  # server

  def init(_) do
    Process.send_after(self(), :send_to_viewer, 200)
    Process.send_after(self(), :start_mobs, 500)
    {:ok, initial_state()}
  end

  def handle_call({:move_mob, mob, dx, dy}, _from, state) do
    # IO.inspect "World move mob"
    new_mob =
      mob
      |> set_pos(mob.x + dx, mob.y + dy)

    if did_move(dx, dy) && in_world(new_mob.x, new_mob.y, state) && can_move_to(new_mob.x, new_mob.y, state) do
      new_matrix =
        state.matrix
        |> update_in([new_mob.y, new_mob.x], fn t -> struct(t, mob: new_mob) end)
        |> update_in([mob.y, mob.x], fn t -> struct(t, mob: nil) end)

      new_state =
        state
        |> put_in([:matrix], new_matrix)

      {:reply, new_mob, new_state}
    else
      {:reply, mob, state}
    end
  end

  def handle_info(:send_to_viewer, state) do
    GenServer.cast(Rikrok.ViewerProxy, {:send, matrix_to_glyph_map(state.matrix)})
    Process.send_after(self(), :send_to_viewer, 100)
    {:noreply, state}
  end

  def handle_info(:start_mobs, state) do
    state
    |> mobs()
    |> Enum.each(fn m -> Rikrok.MobSupervisor.start_child(m) end)

    {:noreply, state}
  end

  defp did_move(dx, dy) do
    dx != 0 || dy != 0
  end

  defp can_move_to(x, y, state) do
    t = get_in(state.matrix, [y, x])
    is_nil(t.mob) && !t.blocker
  end

  defp in_world(x, y, state) do
    0 <= x && x < state.width - 1 && 0 <= y && y < state.height - 1
  end

  defp initial_state do
    layout =
      @world.layout
      |> String.trim()
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.map(&grapheme_row_to_objects/1)

    width = length(hd(layout))
    height = length(layout)

    %{matrix: Tensor.Matrix.new(layout, height, width), width: width, height: height}
  end

  defp grapheme_row_to_objects({grapheme_row, y}) do
    String.graphemes(grapheme_row)
    |> Enum.with_index()
    |> Enum.map(fn {g, x} -> grapheme_to_object(g, x, y) end)
  end

  defp grapheme_to_object(g, x, y) do
    Map.get(@world.key, g)
    |> set_pos(x, y)
    |> set_mob_pos(x, y)
  end

  def set_mob_pos(%{mob: nil} = t, _, _), do: t

  def set_mob_pos(%{mob: mob} = t, x, y) do
    struct(t, mob: set_pos(mob, x, y))
  end

  def set_pos(%{x: _, y: _} = obj, x, y) do
    obj
    |> struct(x: x)
    |> struct(y: y)
  end

  def matrix_to_glyph_map(matrix) do
    matrix
    |> Tensor.Matrix.to_list()
    |> Enum.map(fn row ->
      Enum.map(row, fn terrain ->
        Tuple.to_list(glyph_for(terrain))
      end)
    end)
  end

  def mobs(state) do
    state
    |> each(fn m, _, _ -> m.mob end)
    |> Enum.reject(&is_nil/1)
  end

  def each(%{matrix: matrix, width: width, height: height}, f) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        f.(matrix[y][x], x, y)
      end)
    end)
  end

  defp glyph_for(%{mob: %struct{} = mob}), do: struct.glyph(mob)
  defp glyph_for(%{items: [%struct{} = item | _]}), do: struct.glyph(item)
  defp glyph_for(%struct{} = terrain), do: struct.glyph(terrain)
end
