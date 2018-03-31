defmodule GenWorker do
  @moduledoc """
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

      alias GenWorker.State

      @doc """
      Start GenServer
      """
      def start_link(params \\ nil) do
        state = @options
          |> Keyword.put(:caller, __MODULE__)
          |> Keyword.put(:worker_args, params)
          |> State.init!()
        
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
