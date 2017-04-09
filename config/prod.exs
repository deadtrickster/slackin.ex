use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# SlackinEx.Web.Endpoint.load_from_system_env/1 dynamically.
# Any dynamic configuration should be moved to such function.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :slackin_ex, SlackinEx.Web.Endpoint,
  on_init: {SlackinEx.Web.Endpoint, :load_from_system_env, []},  
  url: [scheme: "https", host: System.get_env("DOMAIN_NAME"), port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :slackin_ex, SlackinEx.Web.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :slackin_ex, SlackinEx.Web.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :slackin_ex, SlackinEx.Web.Endpoint, server: true

# config :slackin_ex,
#   slack_subdomain: "slackinex",
#   logo_url: "https://i.imgur.com/bq7UPJ6.png",
#   contact_email: "slackinex@gmail.com",
#   contact_name: "slackin.ex Team"

case System.get_env("RELEASE") do
  nil -> import_config "prod.release.exs"
  type -> import_config "prod.release.#{type}.exs"
end
