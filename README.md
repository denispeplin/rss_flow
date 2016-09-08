[![Build Status](https://travis-ci.org/denispeplin/rss_flow.svg?branch=master)](https://travis-ci.org/denispeplin/rss_flow)
[![Hex Version](https://img.shields.io/hexpm/v/rss_flow.svg)](https://hex.pm/packages/rss_flow)

# RssFlow

`RSS` processing library for `Elixir` language.

## Features

1. Parsing `XML` from [XmlParser](https://github.com/denispeplin/xml_parser)
format into internal RSS-specific representation (Elixir Map).
2. Parsing directly from `XML` into internal representation.
2. Filtering internal RSS-specific representation on title and description.
3. Outputting from internal representation into
[XmlBuilder](https://github.com/joshnuss/xml_builder) format.
4. Filtering `XML` directly, without transforming into internal format.

## Installation

The package can be installed as:

  1. Add `rss_flow` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rss_flow, "~> 0.1.0"}]
    end
    ```

  2. Ensure `rss_flow` is started before your application:

    ```elixir
    def application do
      [applications: [:rss_flow]]
    end
    ```

## Documentation

Documentation is available [here](https://hexdocs.pm/rss_flow).

## Gotchas

1. This library has no speed optimization itself and uses chain of other libraries,
so it is probably slow.
2. Order of `XML` attributes changes during filtering.
