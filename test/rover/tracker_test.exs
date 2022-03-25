defmodule Rover.TrackerTest do
  use ExUnit.Case, async: true

  alias Rover.Tracker

  describe "when new rover can be placed successfuly" do
    test "when coordinates are within the map rover can be placed" do
      state = %Tracker{map_dimension: {100, 100}}
      response = Tracker.handle_call({:set_rover, {50, 50}}, nil, state)
      expected_state = %{state | next_id: 1, rovers: %{0 => {50, 50}}}

      assert {:reply, "Rover is set at 50, 50", ^expected_state} = response
    end

    test "it puts more than one rover onto the map" do
      %{rovers: rovers} = state = %Tracker{next_id: 1, rovers: %{0 => {13, 45}}, map_dimension: {100, 100}}
      response = Tracker.handle_call({:set_rover, {20, 30}}, nil, state)
      expected_state = %{state | next_id: 2, rovers: Map.put(rovers, 1, {20, 30})}

      assert {:reply, "Rover is set at 20, 30", ^expected_state} = response
    end
  end

  describe "when new rover cannot be placed on the map" do
    setup do: %{tracker: %Tracker{map_dimension: {100, 100}}}

    test "when x coordinate < 0 it cannot be placed", %{tracker: state} do
      response = Tracker.handle_call({:set_rover, {-1, 50}}, nil, state)

      assert {:reply, "Cannot place new router", ^state} = response
    end

    test "when x coordinate greater than map limit it cannot be placed", %{tracker: state} do
      response = Tracker.handle_call({:set_rover, {101, 50}}, nil, state)

      assert {:reply, "Cannot place new router", ^state} = response
    end

    test "when y coordinate < 0 it cannot be placed", %{tracker: state} do
      response = Tracker.handle_call({:set_rover, {50, -1}}, nil, state)

      assert {:reply, "Cannot place new router", ^state} = response
    end

    test "when y coordinate greater than map limit it cannot be placed", %{tracker: state} do
      response = Tracker.handle_call({:set_rover, {50, 101}}, nil, state)

      assert {:reply, "Cannot place new router", ^state} = response
    end

    test "when new rover's coordinates match with already existing rover it cannot be placed" do
      state = %Tracker{next_id: 1, rovers: %{0 => {13, 45}}, map_dimension: {100, 100}}
      response = Tracker.handle_call({:set_rover, {13, 45}}, nil, state)

      assert {:reply, "Cannot place new router", ^state} = response
    end
  end

  describe "when rover is attempted to move and it can move" do
    setup do
      tracker = %Tracker{next_id: 1, rovers: %{0 => {50, 50}}, map_dimension: {100, 100}}
      %{tracker: tracker}
    end

    test "rover moves north", %{tracker: state} do
      response = Tracker.handle_call({:north, 0}, nil, state)
      expected_state = %{state | rovers: %{0 => {50, 49}}}

      assert {:reply, "Successfully moved to 50, 49", ^expected_state} = response
    end

    test "rover moves south", %{tracker: state} do
      response = Tracker.handle_call({:south, 0}, nil, state)
      expected_state = %{state | rovers: %{0 => {50, 51}}}

      assert {:reply, "Successfully moved to 50, 51", ^expected_state} = response
    end

    test "rover moves west", %{tracker: state} do
      response = Tracker.handle_call({:west, 0}, nil, state)
      expected_state = %{state | rovers: %{0 => {49, 50}}}

      assert {:reply, "Successfully moved to 49, 50", ^expected_state} = response
    end

    test "rover moves east", %{tracker: state} do
      response = Tracker.handle_call({:east, 0}, nil, state)
      expected_state = %{state | rovers: %{0 => {51, 50}}}

      assert {:reply, "Successfully moved to 51, 50", ^expected_state} = response
    end
  end

  describe "when rover is attempted to move and it cannot move" do
    test "when rover statys on the north edge and tries to move north it does not move" do
      state = %Tracker{next_id: 1, rovers: %{0 => {50, 0}}, map_dimension: {100, 100}}
      response = Tracker.handle_call({:north, 0}, nil,state)

      assert {:reply, "Cannot move, still at 50, 0", ^state} = response
    end

    test "when rover statys on the south edge and tries to move south it does not move" do
      state = %Tracker{next_id: 1, rovers: %{0 => {50, 100}}, map_dimension: {100, 100}}
      response = Tracker.handle_call({:south, 0}, nil, state)

      assert {:reply, "Cannot move, still at 50, 100", ^state} = response
    end

    test "when rover statys on the west edge and tries to move west it does not move" do
      state = %Tracker{next_id: 1, rovers: %{0 => {0, 50}}, map_dimension: {100, 100}}
      response = Tracker.handle_call({:west, 0}, nil, state)

      assert {:reply, "Cannot move, still at 0, 50", ^state} = response
    end

    test "when rover statys on the east edge and tries to move east it does not move" do
      state = %Tracker{next_id: 1, rovers: %{0 => {100, 50}}, map_dimension: {100, 100}}
      response = Tracker.handle_call({:east, 0}, nil, state)

      assert {:reply, "Cannot move, still at 100, 50", ^state} = response
    end
  end
end
