defmodule HttpApi.Resources.MatchFiltersTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpApi.Resources.MatchFilters

  @opts MatchFilters.init([])

  test "without query params returns match filters" do
    conn =
      :get
      |> conn("/match-filters")
      |> TestHelper.fetch_params()
      |> MatchFilters.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    assert %{
             match_filters: %{
               league_and_season: league_and_season,
               date: date
             }
           } = TestHelper.decode_json(conn.resp_body)

    assert %{league: _, season: _} = Enum.random(league_and_season)
    assert date == ["asc", "desc"]
  end

  test "with query params returns 400" do
    conn =
      :get
      |> conn("/match-filters?any=param")
      |> TestHelper.fetch_params()
      |> MatchFilters.call(@opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert %{error: "Bad request"} = TestHelper.decode_json(conn.resp_body)
  end
end
