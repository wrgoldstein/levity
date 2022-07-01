defmodule Levity.Visualization do
  @moduledoc """
  Generate Vega lite specifications from field content
  """
  @marks ~w(bar line)
  @types ~w(nominal quantitative temporal ordinal)

  @base %{
    "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
    width: 700,
    data: %{
      values: []
    },
    mark: %{ type: "line", tooltip: true },
    encoding: %{
      x: %{
        field: "0",
        type: "temporal",
        axis: %{
          title: "shops.inserted_at"
        }
      },
      y: %{field: "1", type: "quantitative", axis: %{ title: false }}
    }
  }

  def parse(rows, fields) do
    # encoding_x = ...
    # encoding_y = ...
    # mark_type = ...
    @base
    |> put_in([:data, :values], rows)
  end

  # def parse_fields_to_x_encoding(fields) do
  #   first = fields
  #   |> Enum.at(0)
  #   if first.k == "dimension" do

  #   end
  # end
end