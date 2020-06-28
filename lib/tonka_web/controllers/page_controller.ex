defmodule TonkaWeb.PageController do
  use TonkaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", job_groups: generate_data())
  end

  defp generate_data do
    crawlers()
    |> Enum.map(&start_task/1)
    |> Enum.map(&Task.await/1)
  end

  defp crawlers do
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

  defp start_task(crawler) do
    Task.async(fn ->
      data = fetch_data(crawler)

      {crawler.title(), crawler.job_posts_url(), data}
    end)
  end

  defp fetch_data(crawler) do
    crawler.job_posts_url()
    |> Crawly.fetch()
    |> crawler.parse_item()
    |> Map.fetch!(:items)
  end
end
