defmodule InfoSys.Counter do
  use GenServer

  @doc """
  Quoted form the book
  When we want to send async messages, we use `GenServer.cast`. Those functions don't send a reply.

  When we want to send sync messages that return server state, we use `GenServer.call`

  GenServer advantages:

    - We don't need to setup refs for sending and receiving sync messages.
    - The GenServer controls the receive loop, enabling:
      - code upgrading
      - handling of system messages
  """

  #
  # PUBLIC API / CLIENT CODE
  #
  def inc(pid), do: GenServer.cast(pid, :inc)
  def dec(pid), do: GenServer.cast(pid, :dec)

  def val(pid) do
    GenServer.call(pid, :val)
  end

  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val)
  end

  #
  # IMPLEMENTATION / SERVER CODE
  #
  def init(initial_val) do
    {:ok, initial_val}
  end

  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end

  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end
end
