defmodule CheckCalc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CheckCalcWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CheckCalc.PubSub},
      # Start the Endpoint (http/https)
      CheckCalcWeb.Endpoint,
      CheckCalc.Service,
      # Start a worker by calling: CheckCalc.Worker.start_link(arg)
      # {CheckCalc.Worker, arg}
      {Task.Supervisor, name: CheckCalc.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CheckCalc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CheckCalcWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
