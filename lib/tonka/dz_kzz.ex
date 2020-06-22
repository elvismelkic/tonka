defmodule Tonka.DzKzz do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "http://www.dzkzz.hr/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "http://www.dzkzz.hr/index.php/dokumentacija/natjecaji/45-natjecaji-za-zaposljavanje-2020"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("div.list-title a.category")
      |> Enum.map(&extract_job_post_data/1)
      |> IO.inspect()

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
  end

  defp extract_job_post_data(post) do
    [title, _date] = split_by(post, " - ")
    [_title, date] = split_by(post, " - ")
    link = base_url() |> URI.merge(extract_link(post)) |> to_string()

    %{date: date, link: link, title: title}
  end

  defp split_by(post, separator) do
    post |> Floki.text() |> String.split(separator)
  end

  defp extract_link(post) do
    post |> Floki.attribute("href") |> Floki.text()
  end
end
