defmodule Mix.Tasks.Compile.Appsignal do
  use Mix.Task

  def run(_args) do
    {_, _} = Code.eval_file("mix_helpers.exs")
    Mix.Appsignal.Helper.install()
  end
end

defmodule Appsignal.Mixfile do
  use Mix.Project

  def project do
    [
      app: :appsignal,
      version: "1.10.2",
      name: "AppSignal",
      description: description(),
      package: package(),
      source_url: "https://github.com/appsignal/appsignal-elixir",
      homepage_url: "https://appsignal.com",
      test_paths: test_paths(Mix.env()),
      elixir: "~> 1.0",
      compilers: compilers(Mix.env()),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: [main: "Appsignal", logo: "logo.png"],
      dialyzer: [
        plt_add_deps: :transitive,
        plt_add_apps: [:mix],
        ignore_warnings: "dialyzer.ignore-warnings"
      ]
    ]
  end

  defp description do
    "Collects error and performance data from your Elixir applications and sends it to AppSignal"
  end

  defp package do
    %{
      files: [
        "lib",
        "c_src/*.[ch]",
        "mix.exs",
        "mix_helpers.exs",
        "*.md",
        "LICENSE",
        "Makefile",
        "agent.exs",
        "priv/cacert.pem"
      ],
      maintainers: ["Jeff Kreeftmeijer", "Tom de Bruijn"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/appsignal/appsignal-elixir"}
    }
  end

  def application do
    [mod: {Appsignal, []}, applications: [:logger, :decorator, :hackney, :poison]]
  end

  defp compilers(:test_phoenix), do: [:phoenix] ++ compilers(:prod)
  defp compilers(_), do: [:appsignal] ++ Mix.compilers()

  defp test_paths(:test_phoenix), do: ["test/appsignal", "test/mix", "test/phoenix"]
  defp test_paths(_), do: ["test/appsignal", "test/mix"]

  defp elixirc_paths(env) do
    case test?(env) do
      true -> ["lib", "test/support"]
      false -> ["lib"]
    end
  end

  defp test?(:test), do: true
  defp test?(:test_phoenix), do: true
  defp test?(:test_no_nif), do: true
  defp test?(_), do: false

  defp deps do
    poison_version =
      case Version.compare(System.version(), "1.6.0") do
        :lt -> ">= 1.3.0 and < 4.0.0"
        _ -> ">= 1.3.0"
      end

    [
      {:hackney, "~> 1.6"},
      {:poison, poison_version},
      {:decorator, "~> 1.2.3"},
      {:plug, ">= 1.1.0", optional: true},
      {:phoenix, ">= 1.2.0", optional: true, only: [:prod, :test_phoenix, :dev]},
      {:bypass, "~> 0.6.0", only: [:test, :test_phoenix, :test_no_nif]},
      {:plug_cowboy, "~> 1.0", only: [:test, :test_phoenix, :test_no_nif]},
      {:ex_doc, "~> 0.12", only: :dev, runtime: false},
      {:credo, "~> 1.0.0", only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.0.0-rc4", only: [:dev], runtime: false}
    ]
  end
end
