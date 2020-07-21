defmodule GenWorker.MixProject do
  use Mix.Project

  @version "0.0.9"
  @github_url "https://github.com/Kr00lIX/gen_worker"

  def project do
    [
      app: :gen_worker,
      version: @version,
      elixir: ">= 1.4.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Worker behavior that helps to run task at a specific time with a specified frequency.",
      source_url: @github_url,
      package: package(),

      # Docs
      name: "GenWorker",
      docs: docs(),

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.travis": :test],

      # Dev
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
      # mod: {GenWorker.App, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.0"},

      # Test
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, "~> 3.0", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test]},

      # Dev
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  # Settings for publishing in Hex package manager:
  defp package do
    %{
      package: "gen_worker",
      contributors: ["Kr00lIX"],
      maintainers: ["Anatoliy Kovalchuk"],
      links: %{github: @github_url},
      licenses: ["MIT"],
      files: ~w(lib LICENSE.md mix.exs README.md)
    }
  end

  def docs do
    [
      main: "GenWorker",
      source_ref: "v#{@version}",
      extras: ["README.md"],
      source_url: "https://github.com/Kr00lIX/gen_worker"
    ]
  end
end
