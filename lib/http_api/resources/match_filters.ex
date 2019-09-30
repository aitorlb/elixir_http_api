defmodule HttpApi.Resources.MatchFilters do
  @moduledoc """
  Plug that defines a unique plug pipeline for /match-filters requests.
  Always sends JSON responses.
  Since the data is static, succesfull responses are cached so data is queried once.
  """

  # Provides conveniences for building resource plugs.
  use HttpApi.Plugs.Helpers.ResourceBuilder

  @valid_query_params [
    []
  ]
  plug(ValidateQueryParams, @valid_query_params)
  plug(PutPrivateAccept, "application/json")
  plug(LookupCache)
  plug(:query)
  plug(Encode)
  plug(Respond)
  plug(CacheResponse)

  # Function plug that fetches available filters for matches
  defp query(conn, _) do
    match_spec =
      fun do
        {_, %{Div: x, Season: y}} -> [league: x, season: y]
      end

    league_and_season =
      match_spec
      |> Database.select()
      |> Enum.uniq()
      |> Enum.map(&Map.new(&1))
      |> Enum.sort_by(fn %{league: x, season: y} -> {x, y} end, &>=/2)

    match_filters = %{
      league_and_season: league_and_season,
      date: ["asc", "desc"]
    }

    Plug.Conn.put_private(conn, :results, %{match_filters: match_filters})
  end
end
