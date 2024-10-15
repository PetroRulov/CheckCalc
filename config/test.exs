import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :check_calc, CheckCalcWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "714ai6C3hgtbKPvmsZsOwcVQVmk5JE9ZOBkDznnkVXwFM2feza5KO4TO9Y9J6wVk",
  server: false

# In test we don't send emails.
config :check_calc, CheckCalc.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
