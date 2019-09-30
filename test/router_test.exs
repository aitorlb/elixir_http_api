defmodule HttpApi.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpApi.Router

  @opts Router.init([])

  test "handles /api route" do
    conn =
      :get
      |> conn("/api")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 404" do
    conn =
      :get
      |> conn("/missing")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not found"
  end
end
