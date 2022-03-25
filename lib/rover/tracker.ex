defmodule Rover.Tracker do
  use GenServer

  alias __MODULE__

  defstruct [:map_dimension, next_id: 0, rovers: %{}]

  @type direction :: :north | :south | :west | :east

  @spec start_link(%{map_dimension: {}, opts: []}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(%{map_dimension: map_dimension, opts: opts}) do
    GenServer.start_link(__MODULE__, map_dimension, opts)
  end

  @spec move_rover(integer(), direction()) :: String.t()
  def move_rover(rover_id, direction) do
    GenServer.call(__MODULE__, {direction, rover_id})
  end

  @spec setup_new_rover({integer(), integer()}) :: String.t()
  def setup_new_rover(position) do
    GenServer.call(__MODULE__, {:set_rover, position})
  end

  @impl true
  def init(map_dimension), do: {:ok, %Tracker{map_dimension: map_dimension}}

  @impl true
  def handle_call(
        {:set_rover, position},
        _from,
        %Tracker{next_id: next_id, rovers: rovers} = state
      ) do
    if valid_position?(position, state) do
      updated_state = %{state | next_id: next_id + 1, rovers: Map.put(rovers, next_id, position)}
      Rover.Map.draw(updated_state)

      {:reply, "Rover is set at #{elem(position, 0)}, #{elem(position, 1)}", updated_state}
    else
      {:reply, "Cannot place new router", state}
    end
  end

  @impl true
  def handle_call({direction, id}, _from, %Tracker{rovers: rovers} = state) do
    new_coords = coords_after_movement(direction, rovers[id])

    if valid_position?(new_coords, state, id) do
      {new_x, new_y} = new_coords
      updated_state = %{state | rovers: %{rovers | id => new_coords}}
      Rover.Map.draw(updated_state)

      {:reply, "Successfully moved to #{new_x}, #{new_y}", updated_state}
    else
      {x, y} = rovers[id]
      {:reply, "Cannot move, still at #{x}, #{y}", state}
    end
  end

  @spec valid_position?({integer(), integer()}, %Tracker{}, integer() | nil) :: boolean()
  defp valid_position?({x, y}, state, rover_id \\ nil) do
    %{map_dimension: {map_x, map_y}, rovers: rover} = state

    if 0 <= x && x <= map_x && 0 <= y && y <= map_y do
      {_, other_rovers} = Map.pop(rover, rover_id)
      !rover_at?({x, y}, other_rovers)
    else
      false
    end
  end

  @spec coords_after_movement(direction(), {integer(), integer()}) :: {integer(), integer()}
  defp coords_after_movement(direction, {x, y}) do
    case direction do
      :north -> {x, y - 1}
      :south -> {x, y + 1}
      :west -> {x - 1, y}
      :east -> {x + 1, y}
      _ -> {x, y}
    end
  end

  @spec rover_at?({integer(), integer()}, %{}) :: {} | nil
  defp rover_at?(position, rovers) do
    Enum.find(rovers, fn {_, coords} -> coords == position end)
  end
end
