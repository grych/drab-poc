defmodule DrabPoc do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # file name and monitor type for sentix
    file = Application.get_env(:drab_poc, :watch_file)
    monitor = Application.get_env(:drab_poc, :watch_monitor)

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(DrabPoc.Endpoint, []),
      # Start your own worker by calling: DrabPoc.Worker.start_link(arg1, arg2, arg3)
      # worker(DrabPoc.Worker, [arg1, arg2, arg3]),
      worker(Sentix, [ :access_log, [ file ], [monitor: monitor, latency: 1, filter: [:updated]] ]),
      worker(DrabPoc.Presence, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DrabPoc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DrabPoc.Endpoint.config_change(changed, removed)
    :ok
  end
end
