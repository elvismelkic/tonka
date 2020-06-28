defmodule Tonka.DzMup do
  def title, do: "Dom zdravlja MUP-a RH"

  def base_url, do: "https://dzmup.hr/"

  def job_posts_url, do: "https://dzmup.hr/status_natjecaja/aktivan/"

  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("article.single-javna-nabava")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Stream.filter(&last_two_weeks/1)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    item |> Floki.find("h3") |> Floki.text() =~ pattern
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
    title = post |> Floki.find("a") |> Floki.text() |> String.trim()
    date = extract_date(post)
    link = post |> Floki.find("a") |> Floki.attribute("href") |> Floki.text()

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    date_text =
      post
      |> Floki.find("p")
      |> Floki.text()

    [date] = Regex.run(date_regex(), date_text, capture: :first)

    date
  end

  defp date_regex do
    ~r(\d*\d\.\d*\d\.\d*\d*\d\d)
  end
end
