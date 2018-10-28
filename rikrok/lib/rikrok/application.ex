defmodule Rikrok.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Starts workers by calling: Worker.start_link(arg)
    children = [
      {Rikrok.World, strategy: :one_for_one},
      {Rikrok.MobSupervisor, strategy: :one_for_one},
      {Rikrok.ViewerProxy, strategy: :one_for_one},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rikrok.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
