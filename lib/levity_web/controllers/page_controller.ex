defmodule LevityWeb.PageController do
  use LevityWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
