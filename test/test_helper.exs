ExUnit.start()

defmodule TestHelper do
  def fetch_params(conn, opts \\ Plug.Parsers.init(parsers: [])) do
    Plug.Parsers.call(conn, opts)
  end

  def decode_json(string) do
    Poison.decode!(string, keys: :atoms)
  end

  def string_to_date(date_string) do
    date_string
    |> String.split("/")
    |> Enum.reverse()
    |> Enum.join("-")
    |> Date.from_iso8601!()
  end
end
