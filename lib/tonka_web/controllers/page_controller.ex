defmodule TonkaWeb.PageController do
  use TonkaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
