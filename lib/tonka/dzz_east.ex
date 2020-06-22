defmodule Tonka.DzzEast do
  use Crawly.Spider

  def title do
    "Dom zdravlja Zagreb - Istok"
  end

  @impl Crawly.Spider
  def base_url(), do: "http://dzz-istok.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "http://dzz-istok.hr/category/obavijesti/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("li.post.category-natjecaji")
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp extract_job_post_data(post) do
    date = Floki.find(post, ".value") |> Floki.text()
    title_anchor_tag = post |> Floki.find("h2.post-title") |> Floki.find("a")
    link = Floki.attribute(title_anchor_tag, "href") |> Floki.text()
    title = Floki.attribute(title_anchor_tag, "title") |> Floki.text()

    %{date: date, link: link, title: title}
  end
end
