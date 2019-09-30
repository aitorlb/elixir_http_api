defmodule HttpApi.Plugs.CacheResponse do
  @moduledoc """
  Plug to cache succesful responses given the following private key-values:
  cache_key - Atom that identifies the request for the given resource.
  accept    - the accept header of the request (either json or protobuf)
  results   - the data that was used as response body.
  """

  def init(options), do: options

  def call(
        %Plug.Conn{
          state: :sent,
          status: 200,
          private: %{results: results, cache_key: key, accept: accept}
        } = conn,
        _
      ) do
    HttpApi.Cache.set(key, {accept, results})
    conn
  end

  def call(%Plug.Conn{} = conn, _opts), do: conn
end
