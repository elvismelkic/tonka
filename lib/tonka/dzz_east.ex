defmodule Tonka.DzzEast do
  def title, do: "Dom zdravlja Zagreb - Istok"

  def base_url, do: "http://dzz-istok.hr/"

  def job_posts_url, do: "http://dzz-istok.hr/category/obavijesti/"

  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    job_posts_data =
      document
      |> Floki.find("li.post.category-natjecaji")
      |> Stream.filter(&last_two_weeks/1)
      |> Enum.map(&extract_job_post_data/1)

    %Crawly.ParsedItem{items: job_posts_data, requests: []}
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
    date = extract_date(post)
    title_anchor_tag = post |> Floki.find("h2.post-title") |> Floki.find("a")
    link = Floki.attribute(title_anchor_tag, "href") |> Floki.text()
    title = Floki.attribute(title_anchor_tag, "title") |> Floki.text()

    %{date: date, link: link, title: title}
  end

  defp extract_date(post) do
    post |> Floki.find(".value") |> Floki.text()
  end
end
