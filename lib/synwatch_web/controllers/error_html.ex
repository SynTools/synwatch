defmodule SynwatchWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use SynwatchWeb, :html

  embed_templates "error_html/*"
end
