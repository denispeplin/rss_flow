ExUnit.start()

defmodule ExUnit.TestHelpers do
  def read_rss(filename) do
    System.cwd
    |> Path.join("test/files/#{filename}.rss")
    |> File.read!
  end
end
