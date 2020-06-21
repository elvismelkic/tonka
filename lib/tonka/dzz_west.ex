defmodule Tonka.DzzWest do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://dzz-zapad.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://dzz-zapad.hr/natjecaji.php"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("div.card.card-body")
      |> Stream.filter(&filter_by(&1, "Natječaj"))
      |> Enum.map(&extract_job_post_data/1)
      |> IO.inspect()

    %Crawly.ParsedItem{items: [job_posts_data], requests: []}
  end

  defp filter_by(item, pattern) do
    item |> Floki.find("h4") |> Floki.text() =~ pattern
  end

  defp extract_job_post_data(post) do
    title = post |> Floki.find("h4") |> Floki.text()
    date = extract_date(post)
    link = "#{base_url()}#{extract_link(post)}"

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    [date] =
      post
      |> Floki.find("span")
      |> Enum.map(&Floki.text/1)
      |> Enum.filter(&String.contains?(&1, ".2020"))

    date
  end

  defp extract_link(post) do
    post |> Floki.find("a") |> Floki.attribute("href") |> Floki.text()
  end
end
