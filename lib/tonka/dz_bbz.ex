defmodule Tonka.DzBbz do
  def title, do: "Dom zdravlja Bjelovarsko-bilogorske županije"

  def base_url, do: "http://www.dzbbz.hr/"

  def job_posts_url, do: "http://www.dzbbz.hr/index.php/javni-natjecaji.html"

  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("td.list-title a")
      |> Stream.filter(&filter_by(&1, ~r/.*natje.*/i))
      |> Stream.take(5)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp filter_by(item, pattern) do
    Floki.text(item) =~ pattern
  end

  defp extract_job_post_data(post) do
    title = post |> Floki.text() |> String.trim()
    date = extract_date(post)
    link = base_url() |> URI.merge(extract_link(post)) |> to_string()

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    date_regex()
    |> Regex.run(Floki.text(post), capture: :first)
    |> case do
      nil -> ""
      [date] -> date
    end
  end

  defp extract_link(post) do
    post |> Floki.attribute("href") |> Floki.text()
  end

  defp date_regex do
    ~r(\d*\d\.\d*\d\.\d*\d*\d\d)
  end
end
