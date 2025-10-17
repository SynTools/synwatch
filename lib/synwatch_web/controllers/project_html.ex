defmodule SynwatchWeb.ProjectHTML do
  use SynwatchWeb, :html

  embed_templates "project_html/*"

  defp format_dt(nil), do: "-"

  defp format_dt(%NaiveDateTime{} = ndt),
    do: Calendar.strftime(ndt, "%Y-%m-%d · %H:%M")

  defp format_dt(%DateTime{} = dt),
    do: dt |> DateTime.to_naive() |> format_dt()

  defp format_relative(nil), do: ""

  defp format_relative(%DateTime{} = dt), do: format_relative(DateTime.to_naive(dt))

  defp format_relative(%NaiveDateTime{} = ndt) do
    diff = NaiveDateTime.diff(NaiveDateTime.utc_now(), ndt, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)} min ago"
      diff < 86_400 -> "#{div(diff, 3600)} h ago"
      diff < 2 * 86_400 -> "yesterday"
      true -> "#{div(diff, 86_400)} d ago"
    end
  end

  alias Phoenix.LiveView.JS

  defp open_delete(js \\ %JS{}),
    do:
      js
      |> JS.show(
        to: "#confirm-delete",
        transition: {"transition-opacity duration-150", "opacity-0", "opacity-100"}
      )

  defp close_delete(js \\ %JS{}),
    do:
      js
      |> JS.hide(
        to: "#confirm-delete",
        transition: {"transition-opacity duration-150", "opacity-100", "opacity-0"}
      )
end
