defmodule GenWorker do
  @moduledoc ~S"""
  Generic Worker behavior that helps to run task at a specific time with a specified frequency.

  ## Usage
  Define you worker module

  ```elixir
  defmodule MyWorker do
    use GenWorker, run_at: [hour: 13, minute: 59], run_each: [days: 1]

    def run(_prev_args) do
      IO.puts "MyWorker run every day at 13:59"
    end
  end
  ```

  ### Supported options
  *`run_at`* – keyword list with integers values. Supported keys:
   `:year`, `:month`, `:day`, `:hour`, `:minute`, `:second`, `:microsecond`.

    Or you can use map for multiple runs:

    ```elixir
    use GenWorker, run_at: %{"some_key" => [hour: 13, minute: 59], "other_key" => [hour: 14, minute: 00]}, run_each: [days: 1]
    ```

  *`run_each`* - keyword list with integers values. Supported keys: `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes`, `:seconds`, `:milliseconds`. Default is `[days: 1]`

  *`timezone`* - valid timezone. `:utc` - by default. Receive full list of timezones call `Timex.timezones/0`

  You need to implement callback function:
  `c:run/1` that defines worker business logic

   ### Add worker to the application supervision tree:
  ```elixir
    def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        worker(MyWorker, [])
        # ...
      ]

      opts = [strategy: :one_for_one, name: MyApp.Supervisor]
      Supervisor.start_link(children, opts)
    end
  ```
  """

  @doc """
  Callback that should implement task business logic that must be securely processed.
  """
  @callback run(worker_args :: term()) :: worker_args :: term()

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      @behaviour GenWorker
      @options opts

      use GenServer

      alias GenWorker.State

      @doc """
      Start GenServer
      """
      def start_link(params \\ nil) do
        state =
          @options
          |> Keyword.put(:caller, __MODULE__)
          |> Keyword.put(:worker_args, params)
          |> State.init!()

        GenServer.start_link(GenWorker.Server, state, name: __MODULE__)
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :worker,
          restart: :permanent,
          shutdown: 500
        }
      end

      @doc false
      def run(_params) do
        raise "Behaviour function #{__MODULE__}.run/1 is not implemented!"
      end

      defoverridable run: 1, child_spec: 1
    end
  end
end
