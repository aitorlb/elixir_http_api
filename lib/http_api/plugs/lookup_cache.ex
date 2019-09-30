defmodule HttpApi.Plugs.LookupCache do
  @moduledoc """
  Plug to look for cached responses. If the lookup is successful, sends the response
  and halts the plug pipeline. Also, assigns a private key and value in the connection
  that identifies the request to the given resource to be used later for caching
  the response (if the lookup were unsuccessful).
  Expects to find the following private field:
  accept - the accept header of the client (either json or protobuf)
  """

  def init(options), do: options

  def call(
        %Plug.Conn{
          request_path: request_path,
          query_string: query_string,
          private: %{accept: accept}
        } = conn,
        _
      ) do
    ordered_query_string =
      query_string
      |> String.split("&")
      |> Enum.sort()
      |> Enum.join("&")

    key = :"#{request_path <> "-" <> ordered_query_string <> "-" <> accept}"
    conn = Plug.Conn.put_private(conn, :cache_key, key)

    case HttpApi.Cache.get(key) do
      [] ->
        conn

      [{_, {content_type, body}}] ->
        conn
        |> Plug.Conn.put_resp_content_type(content_type)
        |> Plug.Conn.send_resp(200, body)
        |> Plug.Conn.halt()
    end
  end
end
