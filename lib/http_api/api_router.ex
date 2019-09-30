defmodule HttpApi.ApiRouter do
  @moduledoc """
  Main router that forwards requests to the different resource plugs.
  With exception to a particular resource, all responses are in JSON.
  """

  # Provides a set of macros to generate routes.
  use Plug.Router
  # Catches any error and looks for a function handle_errors/2 to call.
  use Plug.ErrorHandler
  # Defines shortcuts to module names.
  alias HttpApi.Plugs.Helpers

  # Matches routes.
  plug(:match)
  # Dispatches responses.
  plug(:dispatch)

  # Lists endpoints
  get "/" do
    Helpers.send_json_resp(conn, 200, %{"endpoints" => ["matches", "match-filters"]})
  end

  # Forwards requests to appropriate resource plugs.
  get("/matches", to: HttpApi.Resources.Matches)
  get("/match-filters", to: HttpApi.Resources.MatchFilters)

  # Default fallback for unrecognized routes.
  match _ do
    Helpers.send_json_resp(conn, 404, %{error: "Not found"})
  end

  # Handles the error catched by Plug.ErrorHandler.
  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    require Logger
    Logger.error("kind: #{kind}\nreason: #{reason}\nstack: #{stack}")
    Helpers.send_json_resp(conn, 500, %{error: "Internal server error"})
  end
end
