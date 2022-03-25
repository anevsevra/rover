defmodule Rover do
  use Application

  def start(_type, _args) do
    children = [
      {Rover.Tracker, %{map_dimension: {30, 30}, opts: [name: Rover.Tracker]}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Rover.Supervisor)
  end
end
