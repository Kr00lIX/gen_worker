defmodule GenWorker do
  @moduledoc """
  This module provides helper functions and extended

  You need to implement callback function:
  * `run/0` that defines worker business logic  
  """

  @doc """
  Callback that should implement task business logic that must be securely processed.
  """
  @callback run(term()) :: term()

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

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      @behaviour GenWorker 
      @options opts

      @doc """
      Start GenServer
      """
      def start_link(params \\ nil) do
        state = %GenWorker.Server.State{
          caller: __MODULE__,
          options: params,
          run_at: Keyword.fetch!(@options, :run_at),
          run_each: Keyword.fetch!(@options, :run_each)
        }

        GenServer.start_link(GenWorker.Server, state, name: __MODULE__)
      end

      @doc false
      def run(_params) do
        raise "Behaviour function #{__MODULE__}.run/1 is not implemented!"
      end

      defoverridable [run: 1]
    end
  end
end
