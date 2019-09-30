defmodule HttpApi.Plugs.Encode do
  @moduledoc """
  Plug to encode the results given the following private key-values:
  results - the data to encode in either json or protobuf
  accept  - the accept header of the request (either json or protobuf)
  """

  def init(options), do: options

  def call(%Plug.Conn{private: %{accept: "application/json", results: results}} = conn, _) do
    results = Poison.encode!(results, pretty: true)
    Plug.Conn.put_private(conn, :results, results)
  end

  def call(
        %Plug.Conn{private: %{accept: "application/x-protobuf", results: results}} = conn,
        struct
      )
      when is_binary(struct) do
    protobuf_struct = String.to_atom("Elixir.HttpApi.Protobuf.#{struct}")
    results = protobuf_struct.encode(results)
    Plug.Conn.put_private(conn, :results, results)
  end
end
