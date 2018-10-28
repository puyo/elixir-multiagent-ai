defmodule Rikrok.MixProject do
  use Mix.Project

  def project do
    [
      app: :rikrok,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Rikrok.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:enm, github: "basho/enm"},
      {:mix_test_watch, "~> 0.9.0", only: [:test]},
      {:msgpax, "~> 0.7"},
      {:tensor, "~> 2.0.0"}
    ]
  end
end
