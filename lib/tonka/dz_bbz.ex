defmodule Tonka.DzBbz do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "http://www.dzbbz.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "http://www.dzbbz.hr/index.php/javni-natjecaji.html"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("td.list-title a")
      |> IO.inspect()
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Stream.filter(&filter_by(&1, date_regex()))
      |> Enum.map(&extract_job_post_data/1)
      |> IO.inspect()

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    Floki.text(item) =~ pattern
  end

  defp extract_job_post_data(post) do
    title = Floki.text(post) |> String.trim()
    date = extract_date(post)
    link = base_url() |> URI.merge(extract_link(post)) |> to_string()

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    [date] = Regex.run(date_regex(), Floki.text(post), capture: :first)

    date
  end

  defp extract_link(post) do
    post |> Floki.attribute("href") |> Floki.text()
  end

  defp date_regex do
    ~r(\d\d\.\d\d\.\d*\d*\d\d)
  end
end
