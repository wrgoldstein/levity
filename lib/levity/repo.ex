defmodule Levity.Repo do
  use Ecto.Repo,
    otp_app: :levity,
    adapter: Ecto.Adapters.SQLite3
end
