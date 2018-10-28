defmodule Rikrok.Mob do
  @moduledoc false

  defstruct inventory: []

  @type t :: %__MODULE__{}

  @callback glyph(t()) :: String.t()
end
