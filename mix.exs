defmodule SlackinEx.Mixfile do
  use Mix.Project

  def project() do
    [app: :slackin_ex,
     version: "0.1.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application() do
    [mod: {SlackinEx.Application, []},
     extra_applications: [:logger, :runtime_tools]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps() do
    [{:phoenix, "~> 1.3"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_html, "~> 2.10"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:prometheus_phoenix, "~> 1.2"},
     {:prometheus_plugs, "~> 1.1"},
     {:prometheus_process_collector, "~> 1.2", override: true},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:hackney, "~> 1.7"},
     {:jsx, "~> 2.8"},
     {:credo, git: "https://github.com/rrrene/credo", only: [:dev, :test], runtime: false},
     {:fuse, "~> 2.4"},
     {:smerl, "~> 0.0.1"},
     {:distillery, "~> 1.3"}]
  end
end
