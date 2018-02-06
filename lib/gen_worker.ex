defmodule GenWorker do
  @moduledoc """
  Documentation for GenWorker.
  """

  @doc """
  Hello world.

  ## Examples

      iex> GenWorker.hello
      :world

  """
  
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      @doc """
      Start GenServer
      """
      def start_link do        
        state = %GenWorker.State{
          caller: __MODULE__,
          run_at: Keyword.fetch!(unquote(opts), :run_at),
          run_each: Keyword.fetch!(unquote(opts), :run_each),
        }    
        GenServer.start_link(GenWorker.Server, state, name: __MODULE__)
      end
    end
  end
end