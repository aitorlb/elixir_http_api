defmodule HttpApi.Cache do
  @moduledoc """
  GenServer that owns a ETS table to store and retrieve cached web responses.

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

  # Inserts a new object into the table; returns false if already exist.
  def set(key, value) do
    :ets.insert_new(__MODULE__, {key, value})
  end

  # Returns the object with the matching key or an empty list.
  def get(key) do
    :ets.lookup(__MODULE__, key)
  end

  ## Server

  # Creates the ETS table.
  def init(_) do
    :ets.new(__MODULE__, [
      :named_table,
      :set,
      :public,
      write_concurrency: true,
      read_concurrency: true
    ])

    {:ok, nil}
  end
end
