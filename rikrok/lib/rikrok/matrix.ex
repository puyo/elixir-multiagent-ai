defmodule Rikrok.Matrix do
  def sub_matrix(matrix, x, y, w, h) do
    ww = Tensor.Matrix.width(matrix)
    wh = Tensor.Matrix.height(matrix)
    xmin = Enum.max(0..x)
    ymin = Enum.max(0..y)
    xmax = Enum.min((x + w)..ww) - 1
    ymax = Enum.min((y + h)..wh) - 1

    rw = xmax - xmin
    rh = ymax - ymin

    new_list =
      Enum.map(ymin..ymax, fn j ->
        Enum.map(xmin..xmax, fn i ->
          matrix[j][i]
        end)
      end)

    Tensor.Matrix.new(new_list, rw, rh)
  end

  def each(matrix, f) do
    w = Tensor.Matrix.width(matrix)
    h = Tensor.Matrix.height(matrix)

    Enum.flat_map(0..(h - 1), fn j ->
      Enum.map(0..(w - 1), fn i ->
        f.(matrix[j][i])
      end)
    end)
  end
end
