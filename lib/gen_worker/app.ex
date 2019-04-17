defmodule GenWorker.App do
  @moduledoc false
  use Application

  def start(_, _) do
    import Supervisor.Spec
    opts = [strategy: :one_for_one, name: GenWorker.Supervisor]
    children = [
        worker(GenWorker.Worker, [])
      ]
    Supervisor.start_link(children, opts)
  end

end
