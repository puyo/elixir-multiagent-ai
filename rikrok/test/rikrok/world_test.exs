defmodule Rikrok.WorldTest do
  use ExUnit.Case

  test "loads the world" do
    assert %{matrix: _} = Rikrok.World.initial_state()
  end
end
