defmodule SynwatchWeb.PageController do
  use SynwatchWeb, :controller

  def home(conn, _params), do: redirect(conn, to: ~p"/dashboard")

  def dashboard(conn, _params), do: render(conn, :home, page_title: "Dashboard")

  def settings(conn, _params), do: render(conn, :settings, page_title: "Settings")
end
