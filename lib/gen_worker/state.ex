defmodule GenWorker.State do
  @moduledoc """
  Configure worker
  """
  alias GenWorker.{State, Error}

  @default_run_each [days: 1]
  @default_run_at [{:microsecond, {1, 0}}]

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

  @typep run_each_options :: [
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

  @type t :: %__MODULE__{
          run_at: run_at_options(),
          run_each: run_each_options(),
          caller: atom(),
          timezone: Timex.TimezoneInfo.t(),
          last_called_at: DateTime.t(),
          worker_args: term()
        }

  @type options :: [
          run_at: run_at_options() | %{(binary() | atom()) => run_at_options()},
          run_each: run_each_options()
        ]

  defstruct [:run_at, :caller, :run_each, :last_called_at, :timezone, :worker_args]

  @doc """
  Init state structure and validate
  """
  @spec init!(options) :: State.t() | no_return() | Exception.t()
  def init!(options) do
    %State{
      caller: options[:caller],
      run_at: validate_run_at!(options[:run_at]),
      run_each: validate_run_each!(options[:run_each]),
      timezone: validate_timezone!(options[:timezone]),
      worker_args: options[:worker_args]
    }
  end

  defp validate_run_at!(run_at) when is_nil(run_at),
    do: %{"default" => @default_run_at}

  defp validate_run_at!(run_at) when is_list(run_at),
    do: %{"default" => run_at_validator!(run_at)}

  defp validate_run_at!(run_at) when is_map(run_at) do
    run_at |> Map.values() |> Enum.each(&run_at_validator!/1)
    run_at
  end

  defp run_at_validator!(run_at) do
    case Timex.set(Timex.now(), run_at) do
      %DateTime{} ->
        Keyword.put_new(run_at, :microsecond, {1, 0})

      {:error, {:bad_option, bad_option}} ->
        raise Error, "Error invalid `#{bad_option}` run_at option."
    end
  end

  defp validate_run_each!(nil) do
    @default_run_each
  end

  defp validate_run_each!(run_each) do
    case Timex.shift(Timex.now(), run_each) do
      %DateTime{} ->
        run_each

      {:error, {:unknown_shift_unit, bad_option}} ->
        raise Error, "Error invalid `#{bad_option}` run_each option."
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
