defmodule Rikrok.MatrixTest do
  use ExUnit.Case

  setup do
    matrix =
      Tensor.Matrix.new(
        [
          [1, 2, 3, 4],
          [11, 12, 13, 14],
          [21, 22, 23, 24],
          [31, 32, 33, 34]
        ],
        4,
        4
      )

    {:ok, matrix: matrix}
  end

  describe "sub_matrix" do
    test "big", %{matrix: matrix} do
      result = Rikrok.Matrix.sub_matrix(matrix, -10, -10, 20, 20)
      expected = matrix
      assert result == expected
    end

    test "small", %{matrix: matrix} do
      result = Rikrok.Matrix.sub_matrix(matrix, 1, 1, 2, 2)
      expected = Tensor.Matrix.new([[12, 13], [22, 23]], 2, 2)
      assert result == expected
    end

    test "1x1", %{matrix: matrix} do
      result = Rikrok.Matrix.sub_matrix(matrix, 1, 1, 1, 1)
      expected = Tensor.Matrix.new([[12]], 1, 1)
      assert result == expected
    end

    test "clipped 1", %{matrix: matrix} do
      result = Rikrok.Matrix.sub_matrix(matrix, 20, 20, 1, 1)
      expected = nil
      assert result == expected
    end

    test "clipped 2", %{matrix: matrix} do
      result = Rikrok.Matrix.sub_matrix(matrix, -2, 1, 4, 4)
      expected = Tensor.Matrix.new([[11, 12], [21, 22], [31, 32]], 3, 2)
      assert result == expected
    end
  end

  describe "flat_map" do
    test "basics" do
      matrix = Tensor.Matrix.new([[1, 2], [3, 4]], 2, 2)
      result = Rikrok.Matrix.flat_map(matrix, fn x -> x end)
      expected = [1, 2, 3, 4]
      assert result == expected
    end
  end
end
