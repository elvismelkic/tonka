defmodule Tonka.DzK do
  def title, do: "Dom zdravlja Karlovac"

  def base_url, do: "https://domzdravlja-karlovac.hr/"

  def job_posts_url, do: "https://domzdravlja-karlovac.hr/aktualni-natjecaji/"

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

    link =
      post
      |> Floki.find("h2.entry-title")
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Floki.text()

    %{date: date, link: link, title: title}
  end
end
