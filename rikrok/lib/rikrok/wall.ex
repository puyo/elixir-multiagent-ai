defmodule Rikrok.Wall do
  @moduledoc false

  @behaviour Rikrok.Terrain

  defstruct x: 0, y: 0, mob: nil, items: [], blocker: true

  def glyph(_t) do
    "#"
  end
end
