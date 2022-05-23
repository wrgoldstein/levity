defmodule Levity.Metrics do
  @moduledoc """
  The Metrics context.
  """

  @spec get_base(base_id :: String.t(), paths :: list(String.t())) :: map()
  def get_base(base_id, paths \\ Path.wildcard("metrics/*.*")) do
    paths
    |> Enum.map(&File.read!/1)
    |> Enum.join("\n")
    |> HXL.decode!()
  end
end
