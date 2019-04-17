defmodule GenWorkerTest do
  use ExUnit.Case, async: true
  doctest GenWorker

  describe "worker each second" do
    defmodule TestWorker do
      use GenWorker, run_at: [microsecond: {1, 0}], run_each: [seconds: 1]

      def run(current_pid) do
        send(current_pid, {:task_worker, Timex.now()})
        current_pid
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

  describe "worker with zero minute" do
    defmodule ZeroMinuteWorker do
      use GenWorker, run_each: [seconds: 1]

      def run(current_pid) do
        send(current_pid, {:task_worker, Timex.now()})
        current_pid
      end
    end

    setup do
      current_pid = self()
      assert {:ok, pid} = ZeroMinuteWorker.start_link(current_pid)
      [pid: pid]
    end

    test "run worker each 30 minutes" do
      assert_receive {:task_worker, time1}, 2000
      assert_receive {:task_worker, time2}, 1000

      assert Timex.before?(time1, time2)
    end
  end
end
