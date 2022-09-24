defmodule InfoSys do
  @backends [InfoSys.Wolfram]

  defmodule Result do
    defstruct score: 0, text: nil, backend: nil
  end

  # `compute` is the main entry point of our service.
  def compute(query, opts \\ []) do
    timeout = opts[:timeout] || 10_000
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @backends

    # Send work to the backend
    backends
    |> Enum.map(&async_query(&1, query, opts))
    # `yield_many` blocks
    |> Task.yield_many(timeout)
    # Explicitly shutdown timed out tasks.
    # This ensure no race condition occurs: the timeout could trigger, while the task could still complete just before calling `Task.shutdown`.
    # `Task.shutdown` handles this scenario, so we would still get the result in that case (having triggered the right side)
    |> Enum.map(fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)
    |> Enum.flat_map(fn
      {:ok, results} -> results
      # match error tuple or nil from timeouts
      _ -> []
    end)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(opts[:limit])
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
