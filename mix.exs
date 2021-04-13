defmodule CodewarsFormatter.MixProject do
  use Mix.Project

  @source_url "https://github.com/codewars/codewars_formatter_ex"
  @version "0.1.0"

  def project do
    [
      app: :codewars_formatter,
      version: @version,
      elixir: "~> 1.11",
      deps: deps(),
      package: package(),
      description: "ExUnit formatter for Codewars"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["kazk"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
