defmodule Tonka.DzKkz do
  use Crawly.Spider

  def title do
    "Dom zdravlja Koprivničko-križevačke županije"
  end

  @impl Crawly.Spider
  def base_url(), do: "https://dzkkz.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://dzkkz.hr/natjecaji/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("a")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Stream.take(5)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    Floki.text(item) =~ pattern
  end

  defp extract_job_post_data(post) do
    title = Floki.text(post)
    link = extract_link(post)
    date = extract_date(post)

    %{date: date, link: link, title: title}
  end

  defp extract_link(post) do
    post |> Floki.attribute("href") |> Floki.text()
  end

  defp extract_date(post) do
    date_regex()
    |> Regex.run(extract_link(post), capture: :first)
    |> format_date()
  end

  defp format_date(nil), do: ""

  defp format_date([date]) do
    [year, month] = String.split(date, "/")

    "#{month}.#{year}"
  end

  defp date_regex do
    ~r(202\d/\d\d)
  end
end
