defmodule Field do
  @derive Jason.Encoder
  defstruct [:v, :k, :t, :n, :s, :q, :id]

  def new(view, kind, type, name, sql) do
    f = %Field{
      v: view,
      k: kind,
      t: type,
      n: name,
      s: sql,
      id: make_id(view, kind, type, name)
    }
    Map.put(f, :q, get_qualified(f))
  end

  def make_id(v, k, t, n) do
    :crypto.hash(:md5, [v, k, t, n])
    |> Base.encode16(case: :lower)
    |> String.slice(0, 10)
  end

  def get_qualified(field) do
   "#{field.v}.#{field.n}"
  end

  def get_qualified_as_qualifier(field) do
    "\"#{field.v}.#{field.n}\""
  end

  def get_sql(field) do
    if field.s do
      "#{field.s} as #{get_qualified_as_qualifier(field)}"
    else
      "#{get_qualified(field)} as #{get_qualified_as_qualifier(field)}"
    end
  end
end

defmodule Levity.Metrics do
  @moduledoc """
  The Metrics context.
  """
  def get_base(base_id) do
    base =
      Path.wildcard("metrics/*.*")
      |> Enum.find(&(Path.basename(&1, ".base") == base_id))
      |> HXL.decode_file!()

    views =
      [base["view"] | Map.keys(base["join"])]
      |> Enum.map(&get_view/1)
      |> Enum.reduce(%{}, fn {view, fields}, acc ->
        Map.put(acc, view, fields)
      end)
    Map.put(base, "views", views)
  end

  def get_view(view_id) do
    Path.wildcard("metrics/*.*")
    |> Enum.find(&(Path.basename(&1, ".view") == view_id))
    |> HXL.decode_file!()
    |> Enum.map(fn {kind, fields} ->
      Enum.map(fields, fn {name, attrs} ->
        Field.new(view_id, kind, attrs["type"], name, Map.get(attrs, "sql"))
      end)
    end)
    |> then(& {view_id, List.flatten(&1)})
  end

  def construct_query(_base, []), do: "select some columns"

  def construct_query(base, fields) do
    root = base["view"]

    joins =
      Enum.reduce(fields, MapSet.new(), fn f, acc -> MapSet.put(acc, f.v) end)
      |> Enum.filter(& &1 != root)
      |> Enum.map(fn view ->
        %{"sql" => sql} = base["join"][view]
        "\n  left join #{view} on \n    #{sql}"
      end)

    field_order = Enum.sort_by(fields, & {&1.k, &1.v, &1.n})
    select = field_order
      |> Enum.map(fn f -> Field.get_sql(f) end)
      |> Enum.map(&"  #{&1}")
      |> Enum.join(",\n")

    measures = Enum.filter(fields, &(&1.k == "measure"))
    grouping =
      Enum.filter(fields, &(&1.k == "dimension"))
      |> Enum.map(&Field.get_qualified_as_qualifier/1)
      |> then(fn g ->
        if Enum.any?(g) && Enum.any?(measures) do
          columns = Enum.join(g, ", ")
          "group by #{columns}"
        end
      end)

    {field_order, "select #{select} from #{root} #{joins} #{grouping}"}
  end
end
