defmodule HttpApi.Plugs.PutPrivateAccept do
  @moduledoc """
  Plug to assign a private key and value in the connection that identifies the
  accept header of the request so other plugs in the pipeline can make use of it.
  """

  def init(options), do: options

  def call(%Plug.Conn{} = conn, mime) when is_binary(mime) do
    Plug.Conn.put_private(conn, :accept, mime)
  end

  def call(%Plug.Conn{} = conn, %{optional: optional, default: default}) do
    accept =
      conn
      |> Plug.Conn.get_req_header("accept")
      |> List.first()

    format = if accept == optional, do: optional, else: default

    Plug.Conn.put_private(conn, :accept, format)
  end
end
