defmodule GenWorker.State do
  @moduledoc """
  Configure worker
  """
  alias GenWorker.{State, Error}

  @default_run_each [days: 1]
  
  @type run_at_options() :: [
    date: Timex.Types.date(),
    year: Timex.Types.year(),
    month: Timex.Types.month(),
    day: Timex.Types.day(),
    hour: Timex.Types.hour(),
    minute: Timex.Types.minute(),
    second: Timex.Types.second(),
    microsecond: Timex.Types.microsecond()
  ]

  @type run_each_options :: [
    microseconds: integer(),
    milliseconds: integer(),
    seconds: integer(),
    minutes: integer(),
    hours: integer(),
    days: integer(),
    weeks: integer(),
    months: integer(),
    years: integer()
  ]

  @type t :: %State{
    run_at: run_at_options(),
    run_each: run_each_options(),
    caller: atom(),
    timezone: Timex.TimezoneInfo.t,
    last_called_at: DateTime.t(),
    worker_args: term()
  }

  @type options :: [
    run_at: run_at_options(),

    run_each: run_each_options()
  ]

  defstruct [:run_at, :caller, :run_each, :last_called_at, :timezone, :worker_args]

  @doc """
  Init state structure and validate
  """
  @spec init!(options) :: State.t() | no_return()  | Exception.t
  def init!(options) do
    %State{
      caller: options[:caller],
      run_at: validate_run_at!(options[:run_at]),
      run_each: validate_run_each!(options[:run_each]),
      timezone: validate_timezone!(options[:timezone]),
      worker_args: options[:worker_args]
    }
  end

  defp validate_run_at!(run_at) when is_nil(run_at) or run_at === [] do
    raise Error, message: "No run_at defined options"
  end
  defp validate_run_at!(run_at) do
    case Timex.set(Timex.now, run_at) do
      %DateTime{} -> run_at
      {:error, {:bad_option, bad_option}}  when is_atom(bad_option) ->
        raise Error, "Error invalid `#{bad_option}` run_at option."
      error ->
        raise Error, "Error invalid run_at option: #{inspect error}"
    end
  end

  defp validate_run_each!(nil) do
    @default_run_each
  end
  defp validate_run_each!(run_each) do
    case Timex.shift(Timex.now, run_each) do
      %DateTime{} -> run_each
      {:error, {:unknown_shift_unit, bad_option}} ->
        raise Error, "Error invalid `#{bad_option}` run_each option."
      error ->
        raise Error, "Error invalid run_each option: #{inspect error}"
    end
  end

  defp validate_timezone!(nil) do
    Application.get_env(:gen_worker, :timezone, :utc)
  end
  defp validate_timezone!(timezone) do
    if not Timex.is_valid_timezone?(timezone) do
      raise Error, "Error invalid `#{timezone}` timezone."
    end

    timezone
  end

end