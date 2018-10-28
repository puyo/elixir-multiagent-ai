defmodule Rikrok.Item do
  @moduledoc false

  @type t :: %__MODULE__{}

  defstruct(x: [])

  @callback glyph(t()) :: String.t()
end
