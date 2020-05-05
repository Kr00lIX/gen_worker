defmodule GenWorker.Callback do
  @moduledoc false

  def run(name, %{caller: caller, worker_args: args} = _state) do
    case GenWorker.Configuration.get(name) do
      callback_fn when is_function(callback_fn) ->
        callback_fn.(caller, args)

      _other ->
        nil
    end
  end
end
