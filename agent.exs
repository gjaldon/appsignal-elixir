defmodule Appsignal.Agent do
  def version, do: "a3e0f83"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "1c69f3afb99150de620f7ed605e48e4d0e3a3470e996974725dd7038605b28a7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "1c69f3afb99150de620f7ed605e48e4d0e3a3470e996974725dd7038605b28a7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "5c4e33f0b64c5848a6e755d0e6d8876750d33dcf6f20a4161053ae9be6fd5322",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "5c4e33f0b64c5848a6e755d0e6d8876750d33dcf6f20a4161053ae9be6fd5322",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "b90655365fb23cc2f5c6a79056520f4b54004039bdcc286f384e41545ceba8ce",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "b90655365fb23cc2f5c6a79056520f4b54004039bdcc286f384e41545ceba8ce",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "38681af7ddba4015f29c59dca210f0a71698ddb85f5f014239b0a2d400f9a55f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "a0949cae6b52231033f035a60458081d32825b9c8bf7953c98b85581ee2f31bb",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "ce04f0484def30697300c62b0a0fbdcd4fce34d553848a68775e8aa3d1e901c3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "ce04f0484def30697300c62b0a0fbdcd4fce34d553848a68775e8aa3d1e901c3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a3e0f83/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
