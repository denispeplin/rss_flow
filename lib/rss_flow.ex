defmodule RssFlow do
  @moduledoc """
  This module uses output provided by XmlParser, transforms it to RSS-specific
  format, filters it, and transforms to format that can be consumed by
  XmlBuilder
  """

  @doc """
  Transform XmlParser format to RSS-specific format
  """
  def parse(data) do
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
  def filter do
  end

  @doc """
  Transforms RSS-specific format to XmlBuilder format
  """
  def generate do
  end
end
