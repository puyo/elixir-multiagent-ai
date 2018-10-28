defmodule Rikrok.MatrixTest do
  use ExUnit.Case

  test "sub_matrix" do
    matrix = Tensor.Matrix.new([[1,2], [3,4]], 2, 2)
    result = Rikrok.Matrix.sub_matrix(matrix, -10, -10, 20, 20)
    expected = result
    assert matrix == expected
  end
end
