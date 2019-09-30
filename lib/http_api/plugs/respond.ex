defmodule HttpApi.Plugs.Respond do
  @moduledoc """
  Plug to send a response given the following private key-values:
  accept  - the accept header of the request (either json or protobuf)
  results - the results already encoded in either json or protobuf
  """

  def init(options), do: options

  def call(%Plug.Conn{private: %{accept: accept, results: results}} = conn, _) do
    conn
    # Sets the content type of the response.
    |> Plug.Conn.put_resp_content_type(accept)
    |> Plug.Conn.send_resp(200, results)
  end
end
