defmodule HttpApi.Plugs.CacheResponseTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpApi.Plugs.CacheResponse

  @opts CacheResponse.init([])

  test "caches a successful response" do
    :get
    |> conn("/path")
    |> Plug.Conn.put_private(:cache_key, :key1)
    |> Plug.Conn.put_private(:accept, "json")
    |> Plug.Conn.put_private(:results, ["results"])
    |> Plug.Conn.send_resp(200, "OK")
    |> CacheResponse.call(@opts)

    assert HttpApi.Cache.get(:key1) == [key1: {"json", ["results"]}]
  end

  test "does not cache a non 200 response" do
    :get
    |> conn("path")
    |> Plug.Conn.put_private(:cache_key, :key2)
    |> Plug.Conn.put_private(:accept, "json")
    |> Plug.Conn.put_private(:results, ["results"])
    |> Plug.Conn.send_resp(404, "Not found")
    |> CacheResponse.call(@opts)

    assert HttpApi.Cache.get(:key2) == []
  end

  test "does not cache a successful response with missing private fields" do
    :get
    |> conn("/path")
    |> Plug.Conn.put_private(:cache_key, :key3)
    |> Plug.Conn.send_resp(200, "OK")
    |> CacheResponse.call(@opts)

    assert HttpApi.Cache.get(:key3) == []
  end
end
