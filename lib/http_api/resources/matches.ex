defmodule HttpApi.Resources.Matches do
  @moduledoc """
  Plug that defines a unique plug pipeline for /matches requests.
  Supports encoding responses as Protocol Buffers when it is speficied
  in the request Accept header; otherwise it falls back to JSON.
  Since the data is static, succesfull responses are cached so data is queried once.
  """

  # Provides conveniences for building resource plugs.
  use HttpApi.Plugs.Helpers.ResourceBuilder

  @valid_query_params [
    [],
    ["date"],
    ["league", "season"],
    ["league", "season", "date"]
  ]
  plug(ValidateQueryParams, @valid_query_params)
  plug(PutPrivateAccept, %{optional: "application/x-protobuf", default: "application/json"})
  plug(LookupCache)
  plug(:query)
  plug(:sort_by_date)
  plug(Encode, "Matches")
  plug(Respond)
  plug(CacheResponse)

  # Function plug to fetch matches by league and season from the database.
  # Handle /matches?league={league}&season={season}
  defp query(%{query_params: %{"season" => season, "league" => league}} = conn, _) do
    match_spec =
      fun do
        {_, %{Div: x, Season: y}} = z when x == ^league and y == ^season -> z
      end

    matches =
      match_spec
      |> Database.select()
      |> Enum.map(&elem(&1, 1))

    put_matches_in_private_results(conn, matches)
  end

  # Function plug to fetch all matches from the database.
  # Handle /matches
  defp query(conn, _) do
    matches =
      Database.all()
      |> Enum.map(&elem(&1, 1))

    put_matches_in_private_results(conn, matches)
  end

  # Wraps the Match list in a Matches Struct and assigns a private field in
  # the connection so the data can be processed further in the plug pipeline.
  defp put_matches_in_private_results(conn, matches) do
    Plug.Conn.put_private(conn, :results, Protobuf.Matches.new(matches: matches))
  end

  # Function plug to sort the matches by date when "date" field is found in the query_params.
  # Only two values are accepted: "asc" or "desc"; otherwise sends a 400 response.
  defp sort_by_date(%{query_params: %{"date" => sort_order}} = conn, _)
       when sort_order not in ["asc", "desc"] do
    Helpers.send_400_json_resp(conn)
  end

  defp sort_by_date(
         %{query_params: %{"date" => sort_order}, private: %{results: %{matches: matches}}} =
           conn,
         _
       ) do
    sorter = if sort_order == "asc", do: &<=/2, else: &>=/2
    date_to_tuple = fn date -> {date.year, date.month, date.day} end
    # Transforms "dd/mm/yyyy" strings into "yyyy-mm-dd" so they can be parsed as Dates.
    mapper = fn %{Date: date_string} ->
      date_string
      |> String.split("/")
      |> Enum.reverse()
      |> Enum.join("-")
      |> Date.from_iso8601!()
      |> date_to_tuple.()
    end

    put_matches_in_private_results(conn, Enum.sort_by(matches, &mapper.(&1), sorter))
  end

  # Catch-all definition for when there is not "date" field.
  defp sort_by_date(conn, _), do: conn
end
