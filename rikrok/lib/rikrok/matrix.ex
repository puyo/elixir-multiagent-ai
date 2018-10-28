defmodule Rikrok.Matrix do
  def sub_matrix(matrix, x, y, w, h) do
    ww = Tensor.Matrix.width(matrix)
    wh = Tensor.Matrix.height(matrix)

    xmin = Enum.max(0..x)
    ymin = Enum.max(0..y)
    xmax = Enum.min((x + w)..ww) - 1
    ymax = Enum.min((y + h)..wh) - 1

    rw = xmax - xmin + 1
    rh = ymax - ymin + 1

    new_list =
      Enum.map(ymin..ymax, fn j ->
        Enum.map(xmin..xmax, fn i ->
          val = matrix[j][i]
          if val == 0 do
            IO.inspect matrix: matrix, val: 0, j: j, i: i
            raise "Uh oh"
          else
            val
          end
        end)
      end)

    Tensor.Matrix.new(new_list, rw, rh)
  end

  def flat_map(matrix, f) do
    w = Tensor.Matrix.width(matrix)
    h = Tensor.Matrix.height(matrix)

    Enum.flat_map(0..(h - 1), fn j ->
      Enum.map(0..(w - 1), fn i ->
        x = matrix[j][i]
        if x == 0 do
          IO.inspect i: i, j: j, matrix: matrix
          raise "Should not be 0: i = #{i} j = #{j}, #{inspect matrix}"
        end
        f.(x)
      end)
    end)
  end

  def mobs(matrix) do
    matrix
    |> Rikrok.Matrix.flat_map(fn t ->
      t.mob
    end)
    |> Enum.reject(&is_nil/1)
  end
end
