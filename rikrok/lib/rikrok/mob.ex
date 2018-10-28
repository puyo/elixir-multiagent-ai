defmodule Rikrok.Mob do
  @moduledoc false

  defstruct inventory: []

  @type t :: %__MODULE__{}

  @callback glyph(t()) :: {String.t(), integer()}

  def dist_squared(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
  end
end
