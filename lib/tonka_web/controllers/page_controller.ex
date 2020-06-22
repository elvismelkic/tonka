defmodule TonkaWeb.PageController do
  use TonkaWeb, :controller

  def index(conn, _params) do
    generate_list()

    render(conn, "index.html")
  end

  defp generate_list do
    [
      Tonka.DzzEast,
      Tonka.DzzCenter,
      Tonka.DzzWest,
      Tonka.DzMup,
      Tonka.DzZgz,
      Tonka.DzKkz,
      Tonka.DzK,
      Tonka.DzKzz,
      Tonka.DzBbz,
      Tonka.DzSisak,
      Tonka.DzVz
    ]
    |> Enum.map(fn elem ->
      [start_urls: [url]] = elem.init()

      data = url |> Crawly.fetch() |> Crawly.parse(elem) |> Map.fetch!(:items)

      {elem.title(), data}
    end)
  end
end
