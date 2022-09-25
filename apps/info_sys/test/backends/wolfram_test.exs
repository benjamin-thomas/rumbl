defmodule InfoSys.Backends.WolframTest do
  use ExUnit.Case, async: true

  test "makes requests, reports results, then terminates" do
    actual = hd(InfoSys.compute("1 + 1"))
    assert "2" = actual.text
  end

  test "no query results reports an empty list" do
    assert [] = InfoSys.compute("none")
  end
end
