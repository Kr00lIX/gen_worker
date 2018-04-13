defmodule GenWorker.MixProject do
  use Mix.Project

  @version "0.0.3"

  def project do
    [
      app: :gen_worker,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Worker behavior that helps to run task at a specific time with a specified frequency.",
      package: package(),

      # Docs
      name: "GenWorker",
      docs: docs(),

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.travis": :test],
      
      # Dev
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GenWorker.App, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.0"},

      {:excoveralls, "~> 0.8", only: :test},

      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.17", only: :dev, runtime: false}
    ]
  end

  # Settings for publishing in Hex package manager:
  defp package do
    %{
      package: "gen_worker",
      contributors: ["Kr00lIX"],
      maintainers: ["Anatoliy Kovalchuk"],
      links: %{github: "https://github.com/Kr00lIX/gen_worker"},
      licenses: ["LICENSE.md"],
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
