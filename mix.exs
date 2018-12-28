defmodule FlowProducers.Mixfile do
  use Mix.Project

  def project, do: [
    app: :flow_producers,
    version: "0.1.1",
    elixir: "~> 1.5",
    start_permanent: Mix.env == :prod,
    description: description(),
    package: package(),
    deps: deps()
  ]

  def application, do: [
    extra_applications: [:logger]
  ]

  defp deps, do: [
    {:gen_stage, ">= 0.14.0"},
    {:flow, ">= 0.14.0", only: :test},
    {:test_probe, "~> 0.0.2", only: :test},
    {:ex_doc, "~> 0.19", only: :dev}
  ]

  defp description, do: """
    Queue and Poller behaviours for Elixir Flow
  """

  defp package, do: [
   files: ["lib", "mix.exs", "README*", "LICENSE*"],
   maintainers: ["Ivan Yurov"],
   licenses: ["MIT"],
   links: %{"GitHub" => "https://github.com/youroff/flow_producers"}
  ]
end
