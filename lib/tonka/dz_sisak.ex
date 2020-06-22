defmodule Tonka.DzSisak do
  use Crawly.Spider

  def title do
    "Dom zdravlja Sisak"
  end

  @impl Crawly.Spider
  def base_url(), do: "https://www.dz-sisak.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.dz-sisak.hr/natjecaji-i-oglasi"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("tr")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    item |> Floki.find("a") |> Floki.text() =~ pattern
  end

  defp extract_job_post_data(post) do
    title = post |> Floki.find("a") |> Floki.text() |> String.trim()
    date = post |> Floki.find("td.list-date") |> Floki.text() |> String.trim()
    link = base_url() |> URI.merge(extract_link(post)) |> to_string()

    %{date: date, link: link, title: title}
  end

  defp extract_link(post) do
    post |> Floki.find("a") |> Floki.attribute("href") |> Floki.text()
  end
end
