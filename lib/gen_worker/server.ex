defmodule GenWorker.Server do
  @moduledoc false
  use GenServer
  require Logger

  alias GenWorker.State

  def init(state) do
    Logger.debug("GenWorker: Init worker with state: #{inspect(state)}")
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:run_work, %{caller: caller, worker_args: worker_args}=state) do
    updated_args = caller.run(worker_args)
    schedule_work(state)
    updated_state = state
      |> Map.put(:last_called_at, time_now(state))
      |> Map.put(:worker_args, updated_args)

    {:noreply, updated_state}
  end

  def delay_in_msec(%State{run_at: run_at, run_each: run_each, last_called_at: last_called_at}=state) do
    current_time = time_now(state)
    current_time
    |> Timex.set(run_at)
    |> (fn call_at ->
          if Timex.before?(current_time, call_at) &&
                (last_called_at == nil || Timex.before?(call_at, last_called_at)) do
            call_at
          else
            Timex.shift(call_at, run_each)
          end
    end).()
    |> Timex.diff(current_time, :milliseconds)
  end

  defp schedule_work(%State{}=state) do
    call_after_msec = delay_in_msec(state)
    Logger.debug("GenWorker run worker after #{call_after_msec} msec")
    Process.send_after(self(), :run_work, call_after_msec)
  end

  defp time_now(%State{timezone: timezone}) do
    Timex.now(timezone)
  end

end
