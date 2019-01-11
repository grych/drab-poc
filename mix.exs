defmodule DrabPoc.Mixfile do
  use Mix.Project

  def project do
    [app: :drab_poc,
     version: "0.9.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {DrabPoc, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext, :sentix, :drab]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
     {:phoenix_pubsub, "~> 1.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:earmark, "~> 1.0.3"},

      {:jason, "~> 1.0"},
      # {:cowboy, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
     #{:drab, "~> 0.7.4"},
     {:drab, path: "../drab"},
     {:logger_file_backend, "~> 0.0.9"},
     {:sentix, "~> 1.0"},
     {:ip2country, "~> 1.0"}
     # {:earmark, "~> 1.3.0"}
     # {:appsignal, "~> 1.0"}
    ]
  end
end
