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

  defp method_chip_class(:GET), do: "bg-green-100 text-green-700"
  defp method_chip_class(:POST), do: "bg-blue-100 text-blue-700"
  defp method_chip_class(:PUT), do: "bg-amber-100 text-amber-800"
  defp method_chip_class(:PATCH), do: "bg-amber-100 text-amber-800"
  defp method_chip_class(:DELETE), do: "bg-red-100 text-red-700"
  defp method_chip_class(:HEAD), do: "bg-gray-200 text-gray-700"
  defp method_chip_class(:OPTIONS), do: "bg-gray-200 text-gray-700"
  defp method_chip_class(_), do: "bg-gray-100 text-gray-700"
end
