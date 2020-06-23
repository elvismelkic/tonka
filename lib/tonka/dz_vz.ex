defmodule Tonka.DzVz do
  use Crawly.Spider

  def title do
    "Dom zdravlja Varaždinske županije"
  end

  @impl Crawly.Spider
  def base_url(), do: "http://dzvz.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "http://dzvz.hr/natjecaji/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("p a")
      |> Stream.filter(&filter_by(&1, ~r/.*aj za zapo.*/i))
      |> Stream.reject(&filter_date(&1, date_regex()))
      |> Stream.filter(&last_two_weeks/1)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    Floki.text(item) =~ pattern
  end

  defp filter_date(item, date) do
    date |> Regex.run(extract_link(item), capture: :first) |> is_nil()
  end

  defp last_two_weeks(post) do
    [day, month, year] =
      post
      |> extract_date()
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)

    Date.diff(Date.utc_today(), date) < 15
  end

  defp extract_job_post_data(post) do
    title = Floki.text(post)
    date = extract_date(post)
    link = base_url() |> URI.merge(extract_link(post)) |> to_string()

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    [date] = Regex.run(date_regex(), extract_link(post), capture: :first)

    String.replace(date, "_", ".")
  end

  defp extract_link(post) do
    post |> Floki.attribute("href") |> Floki.text()
  end

  defp date_regex do
    ~r(\d*\d\_\d*\d\_\d*\d*\d\d)
  end
end
