defmodule GenWorker.ConfigurationTest do
  use ExUnit.Case, async: false
  alias GenWorker.Configuration

  setup do
    on_exit(fn ->
      GenWorker.configure(fn c ->
        c.before(nil)
        c.finally(nil)
      end)
    end)
  end

  test "configure function" do
    GenWorker.configure(fn c ->
      c.before(:ok)
    end)

    assert(Configuration.get(:before) == :ok)
  end

  test "allows only whitelistet functions" do
    assert_raise(UndefinedFunctionError, fn ->
      GenWorker.configure(fn c -> c.hey(:ok) end)
    end)
  end
end
