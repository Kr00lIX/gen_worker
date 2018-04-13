defmodule GenWorker.StateTest do
  use ExUnit.Case, async: true
  alias GenWorker.{State, Error}

  setup do
    options = [
      caller: __MODULE__,
      run_at: [hour: 13, minute: 59], 
      run_each: [days: 1]
    ]
    [options: options]
  end

  test "expect valid config for running once a day", %{options: options} do
    assert %State{
        run_at: [microsecond: {1, 0}, hour: 13, minute: 59], 
        run_each: [days: 1]
      } = State.init!(options)
  end

  describe ":run_at option" do
    test "expect receive default without run_at option", %{options: options} do
      update_options = Keyword.delete(options, :run_at)
      assert %State{run_at: [microsecond: {1, 0}], run_each: [days: 1]} = State.init!(update_options)
    end  

    test "expect raise error for invalid option", %{options: options} do
      update_options = Keyword.put(options, :run_at, [hourss: 10, m: 20])
      assert_raise Error, "Error invalid `hourss` run_at option.",  fn ->
        State.init!(update_options)
      end
    end
  end
 
  describe ":run_each option" do
    test "expect raise error for invalid run_each key option", %{options: options} do
      update_options = Keyword.put(options, :run_each, [d: 1])
      assert_raise Error, "Error invalid `d` run_each option.", fn ->
        State.init!(update_options)
      end
    end

    test "expect get default run each day", %{options: options} do
      update_options = Keyword.delete(options, :run_each)
      assert %State{run_each: [days: 1]} = State.init!(update_options)
    end

    test "expect get each day option", %{options: options} do
      update_options = Keyword.put(options, :run_each, [minutes: 10, seconds: 5])
      assert %State{run_each: [minutes: 10, seconds: 5]} = State.init!(update_options)
    end
  end

  describe ":timezone option" do
    test "expect raise error for invalid option", %{options: options} do
      update_options = Keyword.put(options, :timezone, "invalid")
      assert_raise Error, "Error invalid `invalid` timezone.",  fn ->
        State.init!(update_options)
      end
    end

    test "get default timezone from config", %{options: options} do
      update_options = Keyword.delete(options, :timezone)
      Application.put_env(:gen_worker, :timezone, "Europe/Kiev")
      assert %State{timezone: "Europe/Kiev"} = State.init!(update_options)
    end

    test "expect set valid timezone from options", %{options: options} do
      update_options = Keyword.put(options, :timezone, "Europe/Kiev")
      Application.put_env(:gen_worker, :timezone, :utc)
      assert %State{timezone: "Europe/Kiev"} = State.init!(update_options)   
    end

    test "expect set utc timezone for if not defined", %{options: options} do
      update_options = Keyword.delete(options, :timezone)
      Application.delete_env(:gen_worker, :timezone)
      assert %State{timezone: :utc} = State.init!(update_options)   
    end
  end
end  