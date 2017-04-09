use Mix.Config

config :slackin_ex, SlackinEx.Web.Endpoint,
  server: true

IO.puts(System.cwd())

try do
  import_config "prod.secret.exs"
rescue
  e in Mix.Config.LoadError ->
    case e do
      %Mix.Config.LoadError{error: %File.Error{}} ->
        :ok
      _ ->
        reraise(e, System.stacktrace)
    end
end

