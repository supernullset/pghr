defmodule Pghr.MixProject do
  use Mix.Project

  def project do
    [
      app: :pghr,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Pghr, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.15"}
    ]
  end
end
