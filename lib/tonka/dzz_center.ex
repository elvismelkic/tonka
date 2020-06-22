defmodule Tonka.DzzCenter do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://dzz-centar.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://dzz-centar.hr/o-nama/natjecaji-za-radno-mjesto/aktivni-natjecaji/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("div.dvNaslovnaVijestInfo")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Enum.map(&extract_job_post_data/1)
      |> IO.inspect()

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    extract_title(item) =~ pattern
  end

  defp extract_job_post_data(post) do
    title = extract_title(post)
    date = post |> Floki.find("span.dvNaslovnaVijestDatum") |> Floki.text()
    link = post |> Floki.find("h3.dvNaslovnaVijestNaziv") |> Floki.find("a") |> Floki.attribute("href") |> Floki.text()

    %{date: date, link: link, title: title}
  end

  defp extract_title(post) do
    post |> Floki.find("h3.dvNaslovnaVijestNaziv") |> Floki.find("a") |> Floki.text()
  end
end
