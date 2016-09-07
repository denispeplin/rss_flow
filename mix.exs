defmodule RssFlow.Mixfile do
  use Mix.Project

  def project do
    [app: :rss_flow,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: [
       maintainers: ["Denis Peplin"],
       licenses: ["Apache 2.0"],
       links: %{github: "https://github.com/denispeplin/rss_flow"}
     ],
     description: "RSS processing library for Elixir language.",
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :xml_parser, :xml_builder]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:xml_parser, "~> 0.1.0"},
      {:xml_builder, "~> 0.0.8"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.3.5", only: [:dev]},
      {:credo, "~> 0.4", only: [:dev, :test]}
    ]
  end
end
