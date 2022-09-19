defmodule InfoSys.CounterNonOtp do
  # `inc` and `dec` are asynchronous, meaning we send a message without waiting for a reply
  def inc(pid), do: send(pid, :inc)
  def dec(pid), do: send(pid, :dec)

  # We create a unique reference with `make_ref`. This allows associating the current request with the future response.
  # We then block with `receive`, waiting for this ref to come back with the latest state (val)
  # Or timeout if blocking takes too long
  def val(pid, timeout \\ 5000) do
    ref = make_ref()
    send(pid, {:val, self(), ref})

    receive do
      {^ref, val} ->
        val
    after
      timeout -> exit(:timeout)
    end
  end

  def start_link(initial_val) do
    {:ok, spawn_link(fn -> listen(initial_val) end)}
  end

  # While `inc`, `dec` and `val` represent our public API **interface**,
  # `listen` represents our internal API **implementation**
  defp listen(val) do
    receive do
      :inc ->
        listen(val + 1)

      :dec ->
        listen(val - 1)

      {:val, sender, ref} ->
        send(sender, {ref, val})
        listen(val)
    end
  end
end
