defmodule InfoSys.Cache do
  use GenServer

  @clear_interval :timer.seconds(60)

  def put(name \\ __MODULE__, key, value) do
    true = :ets.insert(tab_name(name), {key, value})
    :ok
  end

  def fetch(name \\ __MODULE__, key) do
    # The ETS API is clunky. `pos` is a one-based index. And returns an `ArgumentError` on key not found.
    {:ok, :ets.lookup_element(tab_name(name), key, 2)}
  rescue
    ArgumentError -> :error
  end

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(opts) do
    state = %{
      interval: opts[:clear_interval] || @clear_interval,
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_clear(state)}
  end

  def handle_info(:clear, state) do
    :ets.delete_all_objects(state.table)
    {:noreply, schedule_clear(state)}
  end

  defp schedule_clear(state) do
    %{state | timer: Process.send_after(self(), :clear, state.interval)}
  end

  defp new_table(name) do
    # `:set` is a type of ETS table that acts as a key-value store.
    # `:named_table` allows us to locate this table by its name.
    # `:public` allows read/write by non-owner processes.
    name
    |> tab_name()
    |> :ets.new([
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
  end

  defp tab_name(name), do: :"#{name}_cache"
end
