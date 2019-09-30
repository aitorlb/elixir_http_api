defmodule HttpApi.Plugs.LookupCacheTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpApi.Plugs.LookupCache

  @opts LookupCache.init([])

  test "assigns a private cache key" do
    conn =
      :get
      |> conn("/path?b=b&a=a")
      # Expects this private key to be set.
      |> Plug.Conn.put_private(:accept, "mime")
      |> TestHelper.fetch_params()
      |> LookupCache.call(@opts)

    assert conn.state == :unset
    assert conn.private.cache_key == :"/path-a=a&b=b-mime"
  end

  test "sends a response with the found content-type header and body" do
    HttpApi.Cache.set(
      :"/matches-league=fantasty&season=202021-application/json",
      {"application/json", "Lots of matches in json"}
    )

    conn =
      :get
      |> conn("/matches?league=fantasty&season=202021")
      # Expects this private key to be set.
      |> Plug.Conn.put_private(:accept, "application/json")
      |> TestHelper.fetch_params()
      |> LookupCache.call(@opts)

    content_type = Plug.Conn.get_resp_header(conn, "content-type") |> List.first()

    assert conn.state == :sent
    assert conn.status == 200
    assert content_type =~ "application/json"
    assert conn.resp_body == "Lots of matches in json"
  end
end
