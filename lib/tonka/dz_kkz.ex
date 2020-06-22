defmodule Tonka.DzKkz do
  use Crawly.Spider

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
      |> Stream.reject(&filter_date(&1, ~r(202\d/\d\d)))
      |> Enum.map(&extract_job_post_data/1)
      |> IO.inspect()

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    Floki.text(item) =~ pattern
  end

  defp filter_date(item, date) do
    date |> Regex.run(extract_link(item), capture: :first) |> is_nil()
  end

  defp extract_job_post_data(post) do
    title = Floki.text(post)
    link = extract_link(post)
    [date] = Regex.run(~r(202\d/\d\d), link, capture: :first)

    %{date: date, link: link, title: title}
  end

  defp extract_link(post) do
    post |> Floki.attribute("href") |> Floki.text()
  end
end
