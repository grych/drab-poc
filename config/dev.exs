use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :drab_poc, DrabPoc.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :drab_poc, DrabPoc.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]
config :drab_poc, :watch_file, "/private/var/log/system.log"
config :drab_poc, :watch_monitor, :kqueue_monitor

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
# config :logger, backends: [{LoggerFileBackend, :log}]
# config :logger, :log,
#   path: "logs/drab_poc.log",
#   level: :debug

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

