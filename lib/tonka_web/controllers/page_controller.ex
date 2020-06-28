defmodule TonkaWeb.PageController do
  use TonkaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", job_groups: generate_data())
  end

  defp generate_data do
    spiders()
    |> Enum.map(&start_task/1)
    |> Enum.map(&Task.await/1)
  end

  defp spiders do
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
  end

  defp start_task(spider) do
    Task.async(fn ->
      [start_urls: [url]] = spider.init()

      data =
        url
        |> Crawly.fetch()
        |> spider.parse_item()

      {spider.title(), url, data.items}
    end)
  end
end
