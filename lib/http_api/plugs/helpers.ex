defmodule HttpApi.Plugs.Helpers do
  @moduledoc """
  Module to hold common logic as to DRY up the code.
  """

  def send_json_resp(conn, status, body, pretty \\ true) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Poison.encode!(body, pretty: pretty))
  end

  def send_400_json_resp(conn) do
    conn
    |> send_json_resp(400, %{"error" => "Bad request"})
    # End processing the plug pipeline
    |> Plug.Conn.halt()
  end

  defmodule ResourceBuilder do
    @moduledoc "Conveniences for building resource plugs."

    defmacro __using__(_) do
      quote do
        # Allows to build a plug pipeline.
        use Plug.Builder

        # Translates functions `fun` to match specifications for use with ets.
        import Ex2ms

        # Allows to access modules without the HttpApi prefix.
        alias HttpApi.{Database, Protobuf}

        # Allows to access the plugs/ modules without the HttpApi.Plugs prefix.
        alias HttpApi.Plugs.{
          CacheResponse,
          Encode,
          Helpers,
          LookupCache,
          PutPrivateAccept,
          Respond,
          ValidateQueryParams
        }
      end
    end
  end
end
