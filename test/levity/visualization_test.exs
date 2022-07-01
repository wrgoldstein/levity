defmodule Levity.VisualizationTest do
  use ExUnit.Case

  alias Levity.Visualization

  describe "parse/2" do
    test "it makes a vegalite specification" do
        fields = [
            %{
                id: "e25d042370",
                k: "dimension",
                n: "updated_at",
                s: nil,
                q: "shops.updated_at",
                t: "timestamp",
                v: "shops"
            },
            %{
                id: "7550e3fdde",
                k: "measure",
                n: "count_shops",
                s: "count(distinct shops.id)",
                q: "shops.count_shops",
                t: "number",
                v: "shops"
            }
        ]

        rows = [
          ["2021-02-02T16:50:47.000000", 4286],
          ["2021-02-03T16:50:47.000000", 3412]
        ]


        assert %{
            "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
            width: 700,
            data: %{
              values: rows
            },
            mark: %{ type: "line", tooltip: true },
            encoding: %{
              y: %{field: "1", type: "quantitative", axis: %{ title: false }},
              x: %{
                field: "0",
                type: "temporal",
                axis: %{
                  title: "shops.inserted_at"
                }
              }
            }
          } == Visualization.parse(rows, fields)
    end
  end
  describe "encoding_x" do
    test "it " do
      fields = [
        %{
            id: "e25d042370",
            k: "dimension",
            n: "fruit",
            s: nil,
            q: "shops.fruit",
            t: "string",
            v: "shops"
        },
        %{
            id: "7550e3fdde",
            k: "measure",
            n: "count_shops",
            s: "count(distinct shops.id)",
            q: "shops.count_shops",
            t: "number",
            v: "shops"
        }
    ]
    
      encoding = Visualization.parse_fields_to_x_encoding(fields)
      assert encoding == %{
        field: "0",
        type: "nominal",
        axis: %{
          title: "shops.fruit"
        }
      }

    end
  end
end
