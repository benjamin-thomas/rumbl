import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :rumbl, Rumbl.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "pg.hello.test",
  database: "rumbl_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rumbl_web, RumblWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "GZc6ziRoamp3OfOwTxm6eXzuJ5hwmAfkvSRck59p94voquww2oLSaBW39H4NxWqf",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :rumbl, Rumbl.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Note: Do not use this value in production
config :pbkdf2_elixir, rounds: 1

config :ex_unit_notifier, notifier: ExUnitNotifier.Notifiers.TmuxNotifier

# https://github.com/lpil/mix-test.watch#clearing-the-console-before-each-run
config :mix_test_watch, clear: true
