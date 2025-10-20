defmodule SynwatchWeb.EndpointHTML do
  use SynwatchWeb, :html

  import SynwatchWeb.Helpers.DateHelpers

  embed_templates "endpoint_html/*"

  defp status_chip_class(code) when is_integer(code) and code >= 100 and code < 200,
    do: "bg-gray-100 text-gray-700"

  defp status_chip_class(code) when code >= 200 and code < 300,
    do: "bg-green-100 text-green-700"

  defp status_chip_class(code) when code >= 300 and code < 400,
    do: "bg-blue-100 text-blue-700"

  defp status_chip_class(code) when code >= 400 and code < 600,
    do: "bg-red-100 text-red-700"

  defp status_chip_class(_), do: "bg-gray-100 text-gray-700"
end
