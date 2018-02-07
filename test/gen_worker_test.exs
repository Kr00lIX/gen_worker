defmodule GenWorkerTest do
  use ExUnit.Case
  doctest GenWorker

  defmodule TestWorker do
    use GenWorker, run_at: [microsecond: {1, 0}], run_each: [seconds: 1]
    
    def run(current_pid) do
      send(current_pid, {:task_worker, Timex.now})
    end
  end

  setup do
    current_pid = self()
    assert {:ok, pid} = TestWorker.start_link(current_pid)
    [pid: pid]
  end

  test "run worker each seconds" do
    assert_receive {:task_worker, time1}, 1000
    assert_receive {:task_worker, time2}, 1000
    refute_receive {:task_worker, _time}

    assert Timex.before?(time1, time2)
  end
end
