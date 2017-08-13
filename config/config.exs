# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :slackin_ex, SlackinEx.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OX6hEGB5vYeWIRJnkqs6RX32m0xab8/X2lgP8t54TeZ5MNADRIkMAZ+bnm8g/wzA",
  render_errors: [view: SlackinEx.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SlackinEx.PubSub,
           adapter: Phoenix.PubSub.PG2],
  instrumenters: [SlackinEx.Web.PhoenixInstrumenter]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sasl, :errlog_type, :error

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
