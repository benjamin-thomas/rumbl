defmodule InfoSys do
  alias InfoSys.Cache

  @backends [InfoSys.Wolfram]

  defmodule Result do
    defstruct score: 0, text: nil, backend: nil
  end

  # `compute` is the main entry point of our service.
  def compute(query, opts \\ []) do
    timeout = opts[:timeout] || 10_000
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @backends

    {uncached_backends, cached_results} = fetch_cached_results(backends, query, opts)

    # Send work to the backend
    uncached_backends
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
    |> write_results_to_cache(query, opts)
    |> Kernel.++(cached_results)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(opts[:limit])
  end

  # It looks like this is what's going on:
  #
  # iex(1)> [[1,2,3] | [4]]
  # [[1, 2, 3], 4]
  # iex(2)> List.flatten([[1,2,3] | [4]])
  # [1, 2, 3, 4]
  # iex(3)> List.flatten([[0] | [1,2,3]])
  # [0, 1, 2, 3]
  # iex(4)> List.flatten([[0] | [1,2,3]])
  # [0, 1, 2, 3]
  #
  #
  # I find it a little strange since we could do away with the flatting as such:
  #
  # iex(5)> [0] ++ [1,2,3]
  # [0, 1, 2, 3]
  # iex(6)> [1,2,3] ++ [4]
  # [1, 2, 3, 4]
  #
  # I suppose the book authors chose to use the first technique for performance/efficiency reasons.
  defp fetch_cached_results(backends, query, opts) do
    {uncached_backends, results} =
      Enum.reduce(
        backends,
        {[], []},
        fn backend, {uncached_backends, acc_results} ->
          case Cache.fetch({backend.name(), query, opts[:limit]}) do
            {:ok, results} -> {uncached_backends, [results | acc_results]}
            :error -> {[backend | uncached_backends], acc_results}
          end
        end
      )

    {uncached_backends, List.flatten(results)}
  end

  defp write_results_to_cache(results, query, opts) do
    Enum.map(results, fn %Result{backend: backend} = result ->
      :ok = Cache.put({backend.name(), query, opts[:limit]}, result)

      result
    end)
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
