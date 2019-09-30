defmodule HttpApi.Router do
  @moduledoc """
  HTTP interface of the application for any incoming web requests.
  Router that defines an initial plug pipeline for requests to pass through
  and forwards /api requests to the api router.
  """

  # Provides a set of macros to generate routes (requires match and dispatch plugs)
  use Plug.Router

  # Logs request information.
  plug(Plug.Logger)
  # Fetches params in the connection (body_params and query_params).
  plug(Plug.Parsers, parsers: [])
  # Matches routes.
  plug(:match)
  # Dispatches responses.
  plug(:dispatch)

  # Forward api requests to api router.
  forward("/api", to: HttpApi.ApiRouter)

  # Default fallback for unrecognized routes.
  match _ do
    send_resp(conn, 404, "Not found")
  end
end
