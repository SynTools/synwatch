defmodule SynwatchWeb.Helpers.DateHelpers do
  def format_dt(nil), do: "-"

  def format_dt(%NaiveDateTime{} = ndt),
    do: Calendar.strftime(ndt, "%Y-%m-%d · %H:%M")

  def format_dt(%DateTime{} = dt),
    do: dt |> DateTime.to_naive() |> format_dt()

  def format_relative(nil), do: ""

  def format_relative(%DateTime{} = dt), do: format_relative(DateTime.to_naive(dt))

  def format_relative(%NaiveDateTime{} = ndt) do
    diff = NaiveDateTime.diff(NaiveDateTime.utc_now(), ndt, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)} min ago"
      diff < 86_400 -> "#{div(diff, 3600)} h ago"
      diff < 2 * 86_400 -> "yesterday"
      true -> "#{div(diff, 86_400)} d ago"
    end
  end
end
