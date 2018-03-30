defmodule GenWorker.MixProject do
  use Mix.Project

  @version "0.0.2"

  def project do
    [
      app: :gen_worker,
      name: "GenWorker",
      description: "Worker behavior that helps to run task at a specific time with a specified frequency.",
      version: @version,
      elixir: "~> 1.4",
      package: package(),      
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
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
      {:timex, "~> 3.0"},

      {:excoveralls, "~> 0.8", only: :test},
      {:ex_doc, "~> 0.17", only: :docs}
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
end
