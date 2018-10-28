defmodule Rikrok.Matrix do
  def sub_matrix(matrix, x, y, w, h) do
    xmin = Enum.max(0..x)
    ymin = Enum.max(0..y)

    xmax = x + w - 1
    ymax = x + h - 1

    new_list =
      Enum.map(ymin..ymax, fn j ->
        Enum.map(xmin..xmax, fn i ->
          matrix[j][i]
        end)
        |> Enum.reject(&is_nil/1)
      end)
      |> Enum.reject(fn row -> length(row) == 0 end)

    nw = length(List.first(new_list) || [])
    nh = length(new_list)

    if nw > 0 && nh > 0 do
      Tensor.Matrix.new(new_list, nw, nh)
    else
      nil
    end
  end

  def flat_map(matrix, f) do
    w = Tensor.Matrix.width(matrix)
    h = Tensor.Matrix.height(matrix)

    Enum.flat_map(0..(h - 1), fn j ->
      Enum.map(0..(w - 1), fn i ->
        x = matrix[j][i]
        f.(x)
      end)
    end)
  end

  def mobs(matrix) do
    matrix
    |> Rikrok.Matrix.flat_map(fn t -> t.mob end)
    |> Enum.reject(&is_nil/1)
  end
end
