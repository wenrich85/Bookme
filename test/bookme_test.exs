defmodule BookmeTest do
  use ExUnit.Case
  doctest Bookme

  test "greets the world" do
    assert Bookme.hello() == :world
  end
end
