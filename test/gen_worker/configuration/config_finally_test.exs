defmodule GenWorker.Configuration.ConfigFinalyTest do
  use ExUnit.Case, async: false

  defmodule ZeroMinuteWorker do
    use GenWorker, run_each: [seconds: 1]

    def run(current_pid) do
      send(current_pid, {:task_worker, DateTime.utc_now()})
      current_pid
    end
  end

  setup do
    current_pid = self()

    GenWorker.configure(fn c ->
      c.finally(fn _module, _args ->
        send(current_pid, :finally_hook)
      end)
    end)

    on_exit(fn ->
      GenWorker.configure(fn c ->
        c.finally(nil)
      end)
    end)

    assert {:ok, pid} = ZeroMinuteWorker.start_link(current_pid)

    [worker: pid]
  end

  test "run worker each second" do
    assert_receive {:task_worker, time1}, 2000
    assert_receive :finally_hook

    assert_receive {:task_worker, time2}, 2000
    assert_receive :finally_hook

    assert Timex.before?(time1, time2)
  end
end
