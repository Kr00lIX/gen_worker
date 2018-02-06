defmodule GenWorkerTest do
  use ExUnit.Case
  doctest GenWorker

  test "greets the world" do
    assert GenWorker.hello() == :world
  end
end
