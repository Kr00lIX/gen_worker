defmodule GenWorker.Server do
  @moduledoc false
  use GenServer
  require Logger

  defmodule State do
    defstruct [:run_at, :caller, :run_each, :last_called_at, :options, :timezone]
  end

  def init(state) do
    Logger.debug("GenWorker: Init worker with state: #{inspect(state)}")
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:run_work, %{caller: caller, options: options, timezone: zone} = state) do
    caller.run(options)
    schedule_work(state)
    {:noreply, %{state | last_called_at: getNow(zone)}}
  end

  defp schedule_work(%State{run_at: run_at, run_each: run_each, last_called_at: last_called_at, timezone: zone}) do
    current_time = getNow(zone)

    call_after_msec =
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

  defp schedule_work(%State{}=state) do
    call_after_msec = delay_in_msec(state)
    Logger.debug("GenWorker run worker after #{call_after_msec} msec")
    Process.send_after(self(), :run_work, call_after_msec)
  end

  defp getNow(nil),  do: Timex.now()
  defp getNow(zone), do: getNow(Timex.is_valid_timezone?(zone), zone)
  defp getNow(true, zone),   do: Timex.now(zone)
  defp getNow(false, _zone), do: Timex.now()
end
