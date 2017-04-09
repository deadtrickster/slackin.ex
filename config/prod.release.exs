use Mix.Config

config :slackin_ex, SlackinEx.Web.Endpoint,
  server: true

import_config "prod.secret.exs"
