defmodule InfoSys do
  @backends [InfoSys.Wolfram]

  defmodule Result do
    defstruct score: 0, text: nil, backend: nil
  end

  # `compute` is the main entry point of our service.
  def compute(query, opts \\ []) do
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @backends

    # Send work to the backend
    backends
    |> Enum.map(&async_query(&1, query, opts))
  end

  # `async_nolink` spawns a new task, isolated from our caller.
  # Scoped to `InfoSys.TaskSupervisor` if I understand things correctly.
  # That way, in case of a timeout/crash, other concurrent processes (HTTP requests) wont't be brought down with it.
  defp async_query(backend, query, opts) do
    Task.Supervisor.async_nolink(
      InfoSys.TaskSupervisor,
      backend,
      :compute,
      [query, opts],
      shutdown: :brutal_kill
    )
  end
end
