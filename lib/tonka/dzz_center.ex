defmodule Tonka.DzzCenter do
  def title, do: "Dom zdravlja Zagreb - Centar"

  def base_url, do: "https://dzz-centar.hr/"

  def job_posts_url,
    do: "https://dzz-centar.hr/o-nama/natjecaji-za-radno-mjesto/aktivni-natjecaji/"

  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("div.dvNaslovnaVijestInfo")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Stream.filter(&last_two_weeks/1)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    extract_title(item) =~ pattern
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
    title = extract_title(post)
    date = extract_date(post)

    link =
      post
      |> Floki.find("h3.dvNaslovnaVijestNaziv")
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Floki.text()

    %{date: date, link: link, title: title}
  end

  defp extract_title(post) do
    post |> Floki.find("h3.dvNaslovnaVijestNaziv") |> Floki.find("a") |> Floki.text()
  end

  defp extract_date(post) do
    post |> Floki.find("span.dvNaslovnaVijestDatum") |> Floki.text()
  end
end
