defmodule EIA.MixProject do
  use Mix.Project

  def project do
    [
      app: :eia,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Change.Application, []}
    ]
  end

  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
