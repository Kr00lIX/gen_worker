defmodule GenWorker.Server do
  @moduledoc false
  use GenServer
  require Logger

  alias GenWorker.{State, Error}

  @spec init(State.t()) :: {:ok, State.t()}
  def init(state) do
    Logger.debug("GenWorker: Init worker with state: #{inspect(state)}")
    schedule_work(state)
    {:ok, state}
  end

  @doc false
  @spec handle_info({:run_work, binary() | atom()}, State.t()) :: {:noreply, State.t()}
  def handle_info(
        {:run_work, key},
        %{caller: caller, worker_args: worker_args, run_at: run_at} = state
      ) do
    updated_args = caller.run(worker_args)

    calc_one_work(run_at[key], key, state)

    updated_state =
      state
      |> Map.put(:last_called_at, time_now(state))
      |> Map.put(:worker_args, updated_args)

    {:noreply, updated_state}
  end

  @spec delay_in_msec(DateTime.t(), State.run_at_options(), State.t()) :: integer()
  def delay_in_msec(current_time, run_at, %State{
        run_each: run_each,
        last_called_at: last_called_at
      }) do
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

  @spec schedule_work(State.t()) :: :ok
  defp schedule_work(%State{run_at: run_at} = state) do
    for {key, time} <- run_at do
      calc_one_work(time, key, state)
    end

    :ok
  end

  @spec calc_one_work(State.run_at_options(), binary() | atom(), State.t()) :: reference()
  defp calc_one_work(time, key, state) do
    call_after_msec = delay_in_msec(time_now(state), time, state)
    Logger.debug("GenWorker run worker \"#{key}\" after #{call_after_msec} msec")
    Process.send_after(self(), {:run_work, key}, call_after_msec)
  end

  @spec time_now(State.t()) :: DateTime.t() | no_return()
  defp time_now(%State{timezone: timezone}) do
    Timex.now(timezone)
    |> case do
      %DateTime{} = datetime -> datetime
      {:error, reason} -> raise Error, "Error invalid timezone #{timezone}: #{inspect(reason)}"
    end
  end
end
