Code.require_file("../../info_sys/test/backends/http_client.exs", __DIR__)
# ExUnitNotifier seems to use some formatting callback mechanism to trigger, not an error.
ExUnit.configure(formatters: [ExUnit.CLIFormatter, ExUnitNotifier])
ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Rumbl.Repo, :manual)
