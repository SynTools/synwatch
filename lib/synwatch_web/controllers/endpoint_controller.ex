defmodule SynwatchWeb.EndpointController do
  use SynwatchWeb, :controller

  alias Synwatch.Accounts.User

  def new(%Plug.Conn{} = conn, _params), do: render(conn, :new, page_title: "Create Endpoint")

  def show(%Plug.Conn{assigns: %{current_user: %User{} = _user}} = conn, %{"id" => _id} = _params) do
    render(conn, :show, page_title: "Endpoint XYZ")
  end
end
