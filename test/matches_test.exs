defmodule HttpApi.Resources.MatchesTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpApi.{Protobuf, Resources.Matches}

  @opts Matches.init([])

  test "without query params returns matches" do
    conn =
      :get
      |> conn("/matches")
      |> TestHelper.fetch_params()
      |> Matches.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{matches: matches} = TestHelper.decode_json(conn.resp_body)

    assert %{
             AwayTeam: _,
             Date: _,
             Div: _,
             FTAG: _,
             FTHG: _,
             FTR: _,
             HTAG: _,
             HTHG: _,
             HTR: _,
             HomeTeam: _,
             Season: _
           } = Enum.random(matches)
  end

  test "with valid query params filters matches" do
    conn =
      :get
      |> conn("/matches?season=201617&league=SP1")
      |> TestHelper.fetch_params()
      |> Matches.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{matches: matches} = TestHelper.decode_json(conn.resp_body)

    assert %{
             AwayTeam: _,
             Date: _,
             Div: "SP1",
             FTAG: _,
             FTHG: _,
             FTR: _,
             HTAG: _,
             HTHG: _,
             HTR: _,
             HomeTeam: _,
             Season: "201617"
           } = Enum.random(matches)
  end

  test "with invalid query params returns 400" do
    conn =
      :get
      |> conn("/matches?invalid=param")
      |> TestHelper.fetch_params()
      |> Matches.call(@opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert %{error: "Bad request"} = TestHelper.decode_json(conn.resp_body)
  end

  test "matches can be Protocol Buffer-encoded" do
    conn =
      :get
      |> conn("/matches")
      |> (&%{&1 | req_headers: [{"accept", "application/x-protobuf"}]}).()
      |> TestHelper.fetch_params()
      |> Matches.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert %Protobuf.Matches{matches: matches} = Protobuf.Matches.decode(conn.resp_body)
    assert %Protobuf.Match{} = Enum.random(matches)
  end

  test "matches can be sorted by date in ascending order" do
    conn =
      :get
      |> conn("/matches?date=asc")
      |> TestHelper.fetch_params()
      |> Matches.call(@opts)

    %{matches: [%{Date: date1}, %{Date: date2} | _]} = TestHelper.decode_json(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    # Date.compare/2 returns :gt if first date is later than the second and :lt for vice versa.
    assert Date.compare(TestHelper.string_to_date(date1), TestHelper.string_to_date(date2)) == :lt
  end

  test "matches can be sorted by date in descending order" do
    conn =
      :get
      |> conn("/matches?date=desc")
      |> TestHelper.fetch_params()
      |> Matches.call(@opts)

    %{matches: [%{Date: date1}, %{Date: date2} | _]} = TestHelper.decode_json(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    # Date.compare/2 returns :gt if first date is later than the second and :lt for vice versa.
    assert Date.compare(TestHelper.string_to_date(date1), TestHelper.string_to_date(date2)) == :gt
  end

  test "with invalid date sorting order returns 400" do
    conn =
      :get
      |> conn("/matches?date=invalid")
      |> TestHelper.fetch_params()
      |> Matches.call(@opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert %{error: "Bad request"} = TestHelper.decode_json(conn.resp_body)
  end
end
