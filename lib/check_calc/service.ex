defmodule CheckCalc.Service do
  @moduledoc false

  use GenServer

  require Logger

  alias CheckCalc.Calculator

  def child_spec(init_args) do
    %{
      id: __MODULE__,
      start: {GenServer, :start_link, [__MODULE__, init_args, [name: __MODULE__]]},
      restart: :permanent
    }
  end

  def calculate(check_params) do
    GenServer.call(__MODULE__, {:calculate, check_params})
  end

  # Callbacks

  @impl true
  def init(_init_args) do
    {:ok, %{ref: nil}}
  end

  @impl true
  def handle_call({:calculate, check_params}, _from, state) do
    task =
      Task.Supervisor.async_nolink(CheckCalc.TaskSupervisor, fn ->
        Calculator.calculate_check(check_params)
      end)

    result = Task.await(task)
    {:reply, result, %{state | ref: task.ref}}
  end
end
