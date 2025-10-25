defmodule SynwatchWeb.TestHTML do
  use SynwatchWeb, :html

  import SynwatchWeb.Helpers.DateHelpers

  embed_templates "test_html/*"

  def run_status_chip_class(:passed), do: "bg-green-100 text-green-700"
  def run_status_chip_class(:failed), do: "bg-red-100 text-red-700"
  def run_status_chip_class(:errored), do: "bg-amber-100 text-amber-800"
  def run_status_chip_class(:running), do: "bg-blue-100 text-blue-700"
  def run_status_chip_class(:queued), do: "bg-gray-100 text-gray-700"
  def run_status_chip_class(_), do: "bg-gray-100 text-gray-700"
end
