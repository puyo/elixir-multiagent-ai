defmodule Rikrok.Terrain do
  @moduledoc false

  @derive [{Msgpax.Packer, fields: [:mob, :items]}]
  defstruct x: 0, y: 0, mob: nil, items: []

  @type t :: %__MODULE__{
    x: integer(),
    y: integer(),
    mob: nil | Rikrok.Mob.t(),
    items: list()
  }

  @callback glyph(t()) :: String.t()
end
