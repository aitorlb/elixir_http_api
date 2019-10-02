defmodule HttpApi.Plugs.PutPrivateAccept do
  @moduledoc """
  Plug to assign a private key and value in the connection that identifies the
  accept header of the request so other plugs in the pipeline can make use of it.
  """

  def init(options), do: options

  def call(%Plug.Conn{} = conn, mime_type) when is_binary(mime_type) do
    Plug.Conn.put_private(conn, :accept, mime_type)
  end

  def call(%Plug.Conn{} = conn, %{optional: optional, default: default}) do
    mime_type =
      conn
      |> Plug.Conn.get_req_header("accept")
      |> List.first()

    accept = if mime_type == optional, do: optional, else: default

    Plug.Conn.put_private(conn, :accept, accept)
  end
end
