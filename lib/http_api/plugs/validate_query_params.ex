defmodule HttpApi.Plugs.ValidateQueryParams do
  @moduledoc """
  Plug to validate the query params before the given resource plug tries to query
  the data. Uses a list of lists as it makes it easier to enforce the number of
  params to allow (league and season must be queried together), even if it's more
  verbose when passing the options to the plug.
  Sends a 400 json encoded response if validation fails.
  """

  def init(options), do: options

  def call(%Plug.Conn{query_params: query_params} = conn, list_of_allowed_keys_lists) do
    sorted_keys =
      query_params
      |> Map.keys()
      |> Enum.sort()

    valid_keys? =
      list_of_allowed_keys_lists
      |> Enum.any?(&(Enum.sort(&1) == sorted_keys))

    if valid_keys? do
      conn
    else
      HttpApi.Plugs.Helpers.send_400_json_resp(conn)
    end
  end
end
