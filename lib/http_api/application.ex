defmodule HttpApi.Application do
  @moduledoc "OTP Application specification"

  use Application

  def start(_type, _args) do
    # All child processes to be supervised.
    children = [
      # Starts up a Cowboy2 server under our app’s
      # supervision tree and registers our router as a plug.
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HttpApi.Router,
        # Set the port per environment
        options: [port: Application.fetch_env!(:http_api, :port)]
      ),
      # The same as {HttpApi.Data, []}
      HttpApi.Database,
      # The same as {HttpApi.Cache, []}
      HttpApi.Cache
    ]

    opts = [strategy: :one_for_one, name: HttpApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
