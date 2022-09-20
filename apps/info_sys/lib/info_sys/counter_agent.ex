defmodule InfoSys.CounterAgent do
  use Agent

  def start_link(init) do
    Agent.start_link(fn -> init end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def inc do
    Agent.update(__MODULE__, &(&1 + 1))
  end

  def dec do
    Agent.update(__MODULE__, fn x -> x - 1 end)
  end
end
