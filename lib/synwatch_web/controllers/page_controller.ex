defmodule SynwatchWeb.PageController do
  use SynwatchWeb, :controller

  plug SynwatchWeb.Plugs.RequireAuth when action in [:home]

  def home(conn, _params) do
    render(conn, :home)
  end
end
