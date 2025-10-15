defmodule SynwatchWeb.PageController do
  use SynwatchWeb, :controller

  plug SynwatchWeb.Plugs.RequireAuth

  def home(conn, _params), do: redirect(conn, to: ~p"/dashboard")

  def dashboard(conn, _params), do: render(conn, :home)

  def projects(conn, _params), do: render(conn, :projects)

  def runs(conn, _params), do: render(conn, :runs)

  def settings(conn, _params), do: render(conn, :settings)
end
