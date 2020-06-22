defmodule Tonka.DzK do
  use Crawly.Spider

  def title do
    "Dom zdravlja Karlovac"
  end

  @impl Crawly.Spider
  def base_url(), do: "https://domzdravlja-karlovac.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://domzdravlja-karlovac.hr/aktualni-natjecaji/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("article.category-aktualni-natjecaji")
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp extract_job_post_data(post) do
    title = post |> Floki.find("h2.entry-title") |> Floki.find("a") |> Floki.text()
    date = post |> Floki.find("span.published") |> Floki.text()
    link = post |> Floki.find("h2.entry-title") |> Floki.find("a") |> Floki.attribute("href") |> Floki.text()

    %{date: date, link: link, title: title}
  end
end
