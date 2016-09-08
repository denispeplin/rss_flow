defmodule RssFlowTest do
  use ExUnit.Case, async: true
  doctest RssFlow
  import ExUnit.TestHelpers, only: [read_rss!: 1]

  def xml_data do
    {:rss, %{version: "2.0"},
     [{:channel, nil,
       [{:title, nil, "Awesome Job"},
        {:description, nil, "Most awesome jobs in the world!"},
        {:link, nil, "http://example.com"},
        {:image, nil, [
          {:url, nil, "http://example.com/images/sample.png"},
          {:title, nil, "Image title (alt)."},
          {:link, nil, "http://example.com/from_image"}
        ]},
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
        link: "http://example.com",
        image: %{
          url: "http://example.com/images/sample.png",
          title: "Image title (alt).",
          link: "http://example.com/from_image"
        }
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
    test "transforms data from XmlParser format to internal format" do
      assert RssFlow.parse(xml_data) == rss_data
    end

    test "transforms data from XML string to internal format" do
      xml_string = read_rss!("jobs_feed")
      assert RssFlow.parse(xml_string) == rss_data
    end
  end

  describe "filter/2" do
    test "filters feed by title" do
      assert RssFlow.filter(rss_data, "Ruby") == rss_data([rss_item_ruby])
    end

    test "filters feed by description" do
      assert RssFlow.filter(rss_data, "onsite") == rss_data([rss_item_elixir])
    end

    test "filters raw XML and outputs raw XML" do
      resulting_data = read_rss!("jobs_feed")
      |> RssFlow.filter("Ruby")
      assert RssFlow.parse(resulting_data) == RssFlow.parse(read_rss!("jobs_feed_ruby"))
    end
  end

  describe "generate/2" do
    test "transforms data from internal format to XmlBuilder format" do
      # Normal thing to do is to compare
      # `assert RssFlow.generate(rss_data) == xml_data` and that's it.
      # But the order of elements (arrays inside tuples) is different,
      # and the results do not match, so the only way for now is to compare
      # the full chain (like in integration tests).
      parsed_rss_data = rss_data
      |> RssFlow.generate
      |> XmlBuilder.generate
      |> XmlParser.parse
      |> RssFlow.parse
      assert parsed_rss_data == rss_data
    end
  end
end
