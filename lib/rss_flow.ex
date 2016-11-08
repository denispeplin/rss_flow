defmodule RssFlow do
  @moduledoc """
  This module uses output provided by XmlParser, transforms it to RSS-specific
  format, filters it, and transforms to format that can be consumed by
  XmlBuilder
  """

  @doc """
  Transform XML string or XmlParser format to RSS-specific format (a map).
  """
  @spec parse(binary | {atom, map, list}) :: map
  def parse(data) when is_binary(data) do
    data |> XmlParser.parse |> parse
  end
  def parse(data) when is_tuple(data) do
    do_parse data
  end

  defp do_parse({:rss, attributes, content}) do
    [channel, items] = parse_channel(content)

    %{
      rss: attributes,
      channel: channel,
      items: items
    }
  end
  defp parse_channel([{:channel, nil, content}]) do
    %{false: channel, true: items} = group_items(content)
    [Enum.into(parse_elements(channel), %{}), parse_elements(items)]
  end

  defp group_items(data) when is_list(data) do
    Enum.group_by data, fn(tuple) -> elem(tuple, 0) == :item end
  end

  defp parse_elements([head | tail]) do
    [parse_elements(head) | parse_elements(tail)]
  end
  defp parse_elements({:item, nil, item}) do
    item |> parse_elements |> Enum.into(%{})
  end
  defp parse_elements({:image, nil, item}) do
    {:image, item |> parse_elements |> Enum.into(%{})}
  end
  defp parse_elements([]), do: []
  defp parse_elements({name, nil, value}), do: {name, value}
  defp parse_elements({name, attributes, value}) do
    {name, Map.merge(attributes, %{value: value})}
  end

  @doc """
  Filter RSS items. Filter can be applied to a map representing XML or directly
  to an XML string.
  """
  @spec filter(map | binary, binary) :: map
  def filter(data, pattern) when is_binary(data) do
    data |> parse |> filter(pattern) |> generate |> XmlBuilder.doc
  end
  def filter(data, pattern) when is_map(data) do
    %{
      rss: data[:rss],
      channel: data[:channel],
      items: Enum.filter(
        data[:items],
        fn(item) -> contains_i?(item[:title] <> item[:description], pattern) end
      )
    }
  end
  defp contains_i?(string, pattern) do
    string
    |> String.downcase
    |> String.contains?(String.downcase(pattern))
  end

  @doc """
  Transform RSS-specific format to XmlBuilder format.
  """
  @spec generate(map) :: {atom, map, list}
  def generate(%{rss: _} = data) do
    {
      :rss,
      data[:rss],
      [{:channel, nil, generate_elements(data[:channel]) ++ generate_items(data[:items])}]
    }
  end
  def generate(%{"rss" => _} = data) do
    {
      :rss,
      data["rss"],
      [{:channel, nil, generate_elements(data["channel"]) ++ generate_items(data["items"])}]
    }
  end

  defp generate_elements(elements) do
    elements
    |> Enum.map(fn({name, raw_value}) -> generate_value(name, raw_value) end)
  end

  defp generate_value(name, raw_value) when is_binary(raw_value), do: {name, nil, raw_value}
  defp generate_value(name, %{value: _} = raw_value) do
    {value, attributes} = Map.pop(raw_value, :value)
    {name, attributes, value}
  end
  defp generate_value(name, %{"value" => _} = raw_value) do
    {value, attributes} = Map.pop(raw_value, "value")
    {name, attributes, value}
  end
  defp generate_value(name, raw_value) when is_map(raw_value) do
    {name, nil, generate_elements(raw_value)}
  end

  defp generate_items(items) do
    items
    |> Enum.map(fn(item) -> {:item, nil, generate_elements(item)} end)
  end
end
