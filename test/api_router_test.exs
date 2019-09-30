defmodule HttpApi.ApiRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpApi.ApiRouter

  @opts ApiRouter.init([])

  test "handles /matches route" do
    conn =
      :get
      |> conn("/matches")
      |> TestHelper.fetch_params()
      |> ApiRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "handles /match-filters route" do
    conn =
      :get
      |> conn("/match-filters")
      |> TestHelper.fetch_params()
      |> ApiRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "lists endpoints" do
    conn =
      :get
      |> conn("/")
      |> ApiRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{endpoints: ["matches", "match-filters"]} = TestHelper.decode_json(conn.resp_body)
  end

  test "returns 404" do
    conn =
      :get
      |> conn("/missing")
      |> ApiRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert %{error: "Not found"} = TestHelper.decode_json(conn.resp_body)
  end
end
