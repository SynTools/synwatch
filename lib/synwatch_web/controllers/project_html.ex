defmodule SynwatchWeb.ProjectHTML do
  use SynwatchWeb, :html

  import SynwatchWeb.Helpers.DateHelpers

  embed_templates "project_html/*"

  defp method_chip_class(:GET), do: "bg-green-100 text-green-700"
  defp method_chip_class(:POST), do: "bg-blue-100 text-blue-700"
  defp method_chip_class(:PUT), do: "bg-amber-100 text-amber-800"
  defp method_chip_class(:PATCH), do: "bg-amber-100 text-amber-800"
  defp method_chip_class(:DELETE), do: "bg-red-100 text-red-700"
  defp method_chip_class(:HEAD), do: "bg-gray-200 text-gray-700"
  defp method_chip_class(:OPTIONS), do: "bg-gray-200 text-gray-700"
  defp method_chip_class(_), do: "bg-gray-100 text-gray-700"
end
