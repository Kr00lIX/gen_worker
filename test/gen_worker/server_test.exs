defmodule GenWorker.ServerTest do
  use ExUnit.Case, async: true
  alias GenWorker.{Server, State}

  describe ".delay_in_msec" do
    setup do
      state = %State{
        run_at: [hour: 13, minute: 59], 
        run_each: [days: 1]
      }
      run_time = Timex.now(:utc) |> Timex.set(hour: 13, minute: 59, second: 0, microsecond: {0, 0})

      [state: state, run_time: run_time]
    end
    
    test "expect valid calc before time", %{state: state, run_time: run_time} do
      time_utc = Timex.set(run_time, hour: 12, minute: 0, second: 0)
      assert :timer.minutes(60 + 59) == Server.delay_in_msec(time_utc, state)
    end

    test "after time", %{state: state, run_time: run_time} do
      time_utc = Timex.set(run_time, hour: 13, minute: 59, second: 1)
      assert :timer.minutes(24 * 60) == Server.delay_in_msec(time_utc, state)

      time_utc = Timex.set(run_time, hour: 14, minute: 0, second: 0)
      assert :timer.minutes(24 * 60 - 1) == Server.delay_in_msec(time_utc, state)
    end

    test "in time", %{state: state, run_time: run_time} do  
      assert :timer.minutes(24 * 60) == Server.delay_in_msec(run_time, state)
    end

    test "in time second call", %{state: state, run_time: run_time} do
      update_state = %{state | last_called_at: run_time}
      time_utc = Timex.now(:utc) |> Timex.set(hour: 13, minute: 59, second: 0)
      assert :timer.minutes(24 * 60) == Server.delay_in_msec(time_utc, update_state)
    end
  end
end  