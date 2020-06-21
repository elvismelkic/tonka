defmodule Tonka.DzMup do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://dzmup.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://dzmup.hr/status_natjecaja/aktivan/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("article.single-javna-nabava")
      |> Stream.filter(&filter_by(&1, "Natječaj"))
      |> Enum.map(&extract_job_post_data/1)
      |> IO.inspect()

    %Crawly.ParsedItem{items: [job_posts_data], requests: []}
  end

  defp filter_by(item, pattern) do
    item |> Floki.find("h3") |> Floki.text() =~ pattern
  end

  defp extract_job_post_data(post) do
    title = post |> Floki.find("a") |> Floki.text() |> String.trim()
    date = extract_date(post)
    link = post |> Floki.find("a") |> Floki.attribute("href") |> Floki.text()

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    post
    |> Floki.find("p")
    |> Floki.text()
  end
end
