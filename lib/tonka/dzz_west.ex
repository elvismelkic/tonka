defmodule Tonka.DzzWest do
  def title, do: "Dom zdravlja Zagreb - Zapad"

  def base_url, do: "https://dzz-zapad.hr/"

  def job_posts_url, do: "https://dzz-zapad.hr/natjecaji.php"

  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("div.card.card-body")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Stream.filter(&last_two_weeks/1)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    item |> Floki.find("h4") |> Floki.text() =~ pattern
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
    title = post |> Floki.find("h4") |> Floki.text()
    date = extract_date(post)
    link = base_url() |> URI.merge(extract_link(post)) |> to_string()

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
