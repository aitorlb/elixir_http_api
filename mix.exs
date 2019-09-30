defmodule HttpApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_api,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      # Add :plug_cowboy to extra_applications
      extra_applications: [:logger, :plug_cowboy],
      mod: {HttpApi.Application, []}
    ]
  end

  defp deps do
    [
      # This will pull in Plug AND Cowboy
      {:plug_cowboy, "~> 2.1"},
      {:nimble_csv, "~> 0.6.0"},
      {:poison, "~> 4.0"},
      {:exprotobuf, "~> 1.2"},
      {:ex2ms, "~> 1.0"}
    ]
  end

  defp releases do
    [
      http_api: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end
end
