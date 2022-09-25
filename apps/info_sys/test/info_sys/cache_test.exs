defmodule InfoSys.CacheTest do
  use ExUnit.Case, async: true
  alias InfoSys.Cache

  # This default value will be available in `setup`.
  # It can be overridden per test with `@tag clear_interval: 123`
  @moduletag clear_interval: 100

  defp assert_shutdown(pid) do
    ref = Process.monitor(pid)

    # We remove the link, otherwise killing the server would also make our test crash.
    Process.unlink(pid)
    Process.exit(pid, :kill)

    assert_receive {:DOWN, ^ref, :process, ^pid, :killed}
  end

  # Polls for `func` to be eventually true.
  defp eventually(func) do
    if func.() do
      true
    else
      Process.sleep(10)
      eventually(func)
    end
  end

  setup %{test: name, clear_interval: clear_interval} do
    # IO.inspect(%{test: name, clear_interval: clear_interval})
    # Start a simple GenServer, passing a shortened clear interval.
    {:ok, pid} = Cache.start_link(name: name, clear_interval: clear_interval)

    # Return the pid to the test context
    {:ok, name: name, pid: pid}
  end

  test "key value pairs can be put and fetched from cache", %{name: name} do
    assert name == :"test key value pairs can be put and fetched from cache"
    assert :ok = Cache.put(name, :key1, :value1)
    assert :ok = Cache.put(name, :key2, :value2)

    assert Cache.fetch(name, :key1) == {:ok, :value1}
    assert Cache.fetch(name, :key2) == {:ok, :value2}
  end

  test "missing entry returns error", %{name: name} do
    assert :error == Cache.fetch(name, :notexists)
  end

  test "clears all entries after clear interval", %{name: name} do
    assert :ok = Cache.put(name, :key1, :value1)
    assert Cache.fetch(name, :key1) == {:ok, :value1}
    assert eventually(fn -> Cache.fetch(name, :key1) == :error end)
  end

  @tag clear_interval: 60_000
  test "values are cleaned up on exit", %{name: name, pid: pid} do
    assert :ok = Cache.put(name, :key1, :value1)
    assert {:ok, :value1} = Cache.fetch(name, :key1)
    assert_shutdown(pid)

    # Restart the GenServer, recycle its original name (no need for the new PID)
    {:ok, _new_pid} = Cache.start_link(name: name)

    # New server works as expected
    assert :ok = Cache.put(name, :key2, :value2)
    assert {:ok, :value2} == Cache.fetch(name, :key2)

    # Old value was cleaned up on shutdown
    assert Cache.fetch(name, :key1) == :error
  end
end
