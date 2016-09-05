defmodule RssFlow do
  @moduledoc """
  This module uses output provided by XmlParser, transforms it to RSS-specific
  format, filters it, and transforms to format that can be consumed by
  XmlBuilder
  """

  @doc """
  Transform XmlParser format to RSS-specific format
  """
  def parse(data) when is_binary(data) do
    data |> XmlParser.parse |> parse
  end
  def parse(data) when is_tuple(data) do
    do_parse data
  end

  defp do_parse({:rss, attributes, content}) do
    [channel, items] = do_parse(content)

    %{
      rss: attributes,
      channel: channel,
      items: items
    }
  end
  defp do_parse([{:channel, nil, content}]) do
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
    parse_elements(item) |> Enum.into(%{})
  end
  defp parse_elements([]), do: []
  defp parse_elements({name, nil, value}), do: {name, value}
  defp parse_elements({name, attributes, value}) do
    {name, Map.merge(attributes, %{value: value})}
  end

  @doc """
  Filter RSS items.
  """
  def filter(data, pattern) when is_map(data) do
    %{
      rss: data[:rss],
      channel: data[:channel],
      items: Enum.filter(data[:items], fn(item) -> contains_i?(item[:title] <> item[:description], pattern) end)
    }
  end
  defp contains_i?(string, pattern) do
    string
    |> String.downcase
    |> String.contains?(String.downcase(pattern))
  end

  @doc """
  Transforms RSS-specific format to XmlBuilder format
  """
  def generate(data) do
    {:rss, data[:rss], [{:channel, nil, generate_channel(data[:channel]) ++ generate_items(data[:items])}]}
  end
  defp generate_channel(channel) do
    generate_elements(channel)
  end
  defp generate_items(items) do
    Enum.map items, fn(item) -> {:item, nil, generate_elements(item)} end
  end
  defp generate_elements(data) do
    Enum.map data, fn({name, sub_value}) ->
      {value, attributes} = generate_value(sub_value)
      {name, attributes, value}
    end
  end
  defp generate_value(value) when is_binary(value), do: {value, nil}
  defp generate_value(value) when is_map(value) do
    Map.pop value, :value
  end
end
