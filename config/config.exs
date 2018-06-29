# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :drab_poc, DrabPoc.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oF0XMqxsrMysQgvn5Vufv29KXJZHLz2xkIl8GQK5S3ATW/2+ww+20Hp4B0YbbehY",
  render_errors: [view: DrabPoc.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DrabPoc.PubSub,
           adapter: Phoenix.PubSub.PG2],
  static_url: [path: "/drab"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# config :drab, DrabPoc.Endpoint, otp_app: :drab_poc

config :drab, DrabPoc.Endpoint,
  disable_controls_when_disconnected: true,
  socket: "/drab/socket",
  drab_store_storage: :local_storage,
  otp_app: :drab_poc

config :phoenix, :template_engines,
  drab: Drab.Live.Engine

config :drab, :presence, true

# config :drab_poc, DrabPoc.Endpoint,
#   instrumenters: [Appsignal.Phoenix.Instrumenter]

# import_config "appsignal.exs"
