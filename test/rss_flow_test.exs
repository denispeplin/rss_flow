defmodule RssFlowTest do
  use ExUnit.Case, async: true
  doctest RssFlow
  alias RssFlow

  def xml_data do
    {:rss, %{version: "2.0"},
     [{:channel, nil,
       [{:title, nil, "Awesome Job"},
        {:description, nil, "Most awesome jobs in the world!"},
        {:link, nil, "http://example.com"},
        {:item, nil,
         [{:title, nil, "Ruby developer"},
          {:description, nil, "Remote position. Mostly backend stuff."},
          {:guid, %{isPermaLink: "true"}, "http://example.com/jobs/1"}]},
        {:item, nil,
         [{:title, nil, "Backend Elixir developer"},
          {:description, nil, "Onsite position"},
          {:guid, %{isPermaLink: "true"}, "http://example.com/jobs/4"}]}]}]}
  end

  def rss_data do
    %{
      rss: %{version: "2.0"},
      channel: %{
        title: "Awesome Job",
        description: "Most awesome jobs in the world!",
        link: "http://example.com"
      },
      items: [%{
          title: "Ruby developer",
          description: "Remote position. Mostly backend stuff.",
          guid: %{
            value: "http://example.com/jobs/1",
            isPermaLink: "true"
          }
        },
        %{
          title: "Backend Elixir developer",
          description: "Onsite position",
          guid: %{
            value: "http://example.com/jobs/4",
            isPermaLink: "true"
          }
        }]}
  end

  describe "parse/1" do
    test "transforms data to internal format" do
      assert RssFlow.parse(xml_data) == rss_data
    end
  end
end
