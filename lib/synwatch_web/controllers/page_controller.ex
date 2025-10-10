defmodule SynwatchWeb.PageController do
  use SynwatchWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
