defmodule SynwatchWeb.SettingsController do
  use SynwatchWeb, :controller

  def index(conn, _params) do
    render(conn, :index, page_title: "Settings")
  end
end
