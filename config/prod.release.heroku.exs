use Mix.Config

config :slackin_ex, SlackinEx.Web.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto]]
