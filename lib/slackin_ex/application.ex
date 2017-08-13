defmodule SlackinEx.Application do

  @moduledoc """
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    SlackinEx.Metrics.Exporter.setup()
    SlackinEx.Metrics.PipelineInstrumenter.setup()
    SlackinEx.Web.PhoenixInstrumenter.setup()
    SlackinEx.Slack.setup()
    SlackinEx.Slack.preflight_check()

    :fuse_event.add_handler(SlackinEx.Events.FuseHandler, [])

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(SlackinEx.Web.Endpoint, []),
      # Start your own worker by calling: SlackinEx.Worker.start_link(arg1, arg2, arg3)
      worker(SlackinEx.Slack, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackinEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
