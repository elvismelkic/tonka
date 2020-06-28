defmodule Tonka.DzZgz do
  use Crawly.Spider

  def title do
    "Dom zdravlja Zagrebačke županije"
  end

  @impl Crawly.Spider
  def base_url(), do: "http://www.domzdravlja-zgz.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "http://www.domzdravlja-zgz.hr/informacije/javni-natjecaji/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("a")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*radni.*/i))
      |> Stream.take(5)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    Floki.text(item) =~ pattern
  end

  defp extract_job_post_data(post) do
    title = Floki.text(post)
    date = extract_date(post)
    link = post |> Floki.attribute("href") |> Floki.text()

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    date_regex()
    |> Regex.run(Floki.text(post), capture: :first)
    |> format_date()
  end

  defp format_date(nil), do: ""
  defp format_date([date]), do: date

  defp date_regex do
    ~r(\d*\d\.\d*\d\.\d*\d*\d\d)
  end
end
