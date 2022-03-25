defmodule Rover.Map do
  @spec draw(%{
          :map_dimension => {integer(), integer()},
          :rovers => %{integer() => {integer(), integer()}}
        }) :: :ok
  def draw(%{map_dimension: {map_x, map_y}, rovers: rovers}) do
    rovers_grouped_by_y = Enum.group_by(rovers, fn {_, {_, y}} -> y end)

    (horizontal_border(map_x) <>
       Enum.reduce(
         0..map_y,
         "",
         fn y, rows ->
           rows <>
             "|" <>
             draw_line(map_x, Map.get(rovers_grouped_by_y, y, %{})) <>
             "|\n"
         end
       ) <>
       horizontal_border(map_x))
    |> IO.puts()
  end

  @spec draw_line(integer(), {integer(), {integer(), integer()}}) :: String.t()
  defp draw_line(map_x, rovers) do
    rovers_grouped_by_x = Enum.group_by(rovers, fn {_, {x, _}} -> x end, fn {i, _} -> i end)

    Enum.reduce(
      0..map_x,
      "",
      fn
        x, acc ->
          acc <>
            if rovers_grouped_by_x[x] do
              List.first(rovers_grouped_by_x[x]) |> Integer.to_string()
            else
              " "
            end
      end
    )
  end

  @spec horizontal_border(integer()) :: String.t()
  defp horizontal_border(length) do
    Enum.reduce(0..length, " ", fn _, header -> header <> "_" end) <> "\n"
  end
end
