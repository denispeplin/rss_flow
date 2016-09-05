defmodule RssFlowTest do
  use ExUnit.Case, async: true
  doctest RssFlow

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

  def rss_meta do
    %{
      rss: %{version: "2.0"},
      channel: %{
        title: "Awesome Job",
        description: "Most awesome jobs in the world!",
        link: "http://example.com"
      }
    }
  end

  def rss_item_ruby do
    %{
        title: "Ruby developer",
        description: "Remote position. Mostly backend stuff.",
        guid: %{
          value: "http://example.com/jobs/1",
          isPermaLink: "true"
        }
      }
  end

  def rss_item_elixir do
    %{
      title: "Backend Elixir developer",
      description: "Onsite position",
      guid: %{
        value: "http://example.com/jobs/4",
        isPermaLink: "true"
      }
    }
  end

  def rss_items(items) do
    %{items: items}
  end

  def rss_data(items \\ [rss_item_ruby, rss_item_elixir]) do
    Map.merge(rss_meta, rss_items(items))
  end

  describe "parse/1" do
    test "transforms data to internal format" do
      assert RssFlow.parse(xml_data) == rss_data
    end
  end

  describe "filter/2" do
    test "filters feed by title" do
      assert RssFlow.filter(rss_data, "Ruby") == rss_data([rss_item_ruby])
    end

    test "filters feed by description" do
      assert RssFlow.filter(rss_data, "onsite") == rss_data([rss_item_elixir])
    end
  end
end
