defmodule HttpApi.Database do
  @moduledoc """
  GenServer that owns a ETS table to store and retrieve the football results.
  The data is loaded on application start and the results are saved as Protobuf
  Structs, so it will be easy to encode them afterwards either to json (with
  poison) or protobuf (with exprotobuf).

  The purpose of this process is to create and keep the ETS table alive,
  while providing a public api to the table. ETS operations won’t go through
  the server process and instead will be handled immediately in the client process.
  """

  # Provides access to the GenServer API.
  use GenServer

  ## Client

  # Starts the ETS table owner process.
  def start_link(_) do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  # Returns a list of all objects in the table.
  def all do
    :ets.tab2list(__MODULE__)
  end

  # Returns a list of all objects in the table matched to the match specification.
  def select(match_spec) do
    :ets.select(__MODULE__, match_spec)
  end

  ## Server

  # Creates the ETS table.
  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :set, :protected, read_concurrency: true]
    )

    load_data()
    {:ok, nil}
  end

  # Loads the data from the CSV file to the ETS table.
  defp load_data do
    Application.app_dir(:http_api, "priv/Data.csv")
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Enum.each(fn [id | values] ->
      match =
        values
        |> process_values()
        |> HttpApi.Protobuf.Match.new()

      :ets.insert(__MODULE__, {id, match})
    end)
  end

  # Processes the row values so they can be used to initialize a Match struct.
  defp process_values([
         league,
         season,
         date,
         home_team,
         away_team,
         fthg,
         ftag,
         ftr,
         hthg,
         htag,
         htr
       ]) do
    [
      Div: league,
      Season: season,
      Date: date,
      HomeTeam: home_team,
      AwayTeam: away_team,
      FTHG: String.to_integer(fthg),
      FTAG: String.to_integer(ftag),
      FTR: ftr,
      HTHG: String.to_integer(hthg),
      HTAG: String.to_integer(htag),
      HTR: htr
    ]
  end
end
