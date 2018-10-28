defmodule Rikrok.Ground do
  @moduledoc false

  @behaviour Rikrok.Terrain

  defstruct x: 0, y: 0, mob: nil, items: [], blocker: false

  def glyph(_t) do
    "."
  end
end
