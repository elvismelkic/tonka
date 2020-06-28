defmodule Tonka.DzKzz do
  def title, do: "Dom zdravlja Krapinsko-zagorske županije"

  def base_url, do: "http://www.dzkzz.hr/"

  def job_posts_url,
    do: "http://www.dzkzz.hr/index.php/dokumentacija/natjecaji/45-natjecaji-za-zaposljavanje-2020"

  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("div.list-title a.category")
      |> Stream.filter(&last_two_weeks/1)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp last_two_weeks(post) do
    [day, month, year] =
      post
      |> extract_date()
      |> String.split(".")
      |> Stream.reject(fn str -> str == "" end)
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)

    Date.diff(Date.utc_today(), date) < 15
  end

  defp extract_job_post_data(post) do
    [_date, title] = split_by(post, " - ")
    date = extract_date(post)
    link = base_url() |> URI.merge(extract_link(post)) |> to_string()

    %{date: date, link: link, title: title}
  end

  defp split_by(post, separator) do
    post |> Floki.text() |> String.split(separator)
  end

  defp extract_date(post) do
    [date, _title] = split_by(post, " - ")

    date
  end

  defp extract_link(post) do
    post |> Floki.attribute("href") |> Floki.text()
  end
end
