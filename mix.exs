defmodule FlowProducers.Mixfile do
  use Mix.Project

  def project do
    [
      app: :flow_producers,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps, do: [
    {:gen_stage, "~> 0.12.2"},
    {:flow, "~> 0.12", only: :test},
    {:test_probe, "~> 0.0.2", only: :test}
  ]

  defp description, do: """
    Queue and Poller behaviours for Elixir Flow
  """

  defp package, do: [
   files: ["lib", "mix.exs", "README*", "LICENSE*"],
   maintainers: ["Ivan Yurov"],
   licenses: ["MIT"],
   links: %{"GitHub" => "https://github.com/youroff/monex"}
  ]
end
