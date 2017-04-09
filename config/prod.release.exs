use Mix.Config

config :slackin_ex, SlackinEx.Web.Endpoint,
  server: true

if File.exists?("prod.secret.exs") do
  import_config "prod.secret.exs"
end
