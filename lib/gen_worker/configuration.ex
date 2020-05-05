defmodule GenWorker.Configuration do
  @moduledoc """
  Handles GenWorker configurations.
  """

  @params [
    init: "Starts on start server.",
    before: "Defines before hook.",
    finally: "Defines finally hook"
  ]

  @doc """
  Accepts a keyword of options.
  Puts options into application environment.
  Allows only whitelisted options.
  """
  def add(opts) do
    opts
    |> Enum.each(fn {key, val} ->
      if Enum.member?(Keyword.keys(@params), key) do
        Application.put_env(:gen_worker, key, val)
      end
    end)
  end

  @doc "Returns the value associated with key."
  def get(key), do: Application.get_env(:gen_worker, key)

  @doc "Returns all options."
  def all, do: Application.get_all_env(:gen_worker)

  @doc """
  Allows to set the config options.
  See `GenWorker.configure/1`.
  """
  def configure(func), do: func.(GenWorker.Configuration)

  @params
  |> Enum.each(fn {func, doc} ->
    @doc """
    #{doc}
    """
    def unquote(func)(value) do
      GenWorker.Configuration.add([{unquote(func), value}])
    end
  end)
end
