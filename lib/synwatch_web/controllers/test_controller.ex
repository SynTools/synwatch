defmodule SynwatchWeb.TestController do
  use SynwatchWeb, :controller

  alias Synwatch.Accounts.User

  def new(
        %Plug.Conn{assigns: %{current_user: %User{} = _user}} = conn,
        %{"project_id" => _project_id, "endpoint_id" => _endpoint_id} = _params
      ) do
    render(conn, :new, page_title: "Create Test")
  end

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = _user}} = conn,
        %{"id" => _id, "project_id" => _project_id, "endpoint_id" => _endpoint_id} = _params
      ) do
    render(conn, :show, page_title: "Test XYZ")
  end
end
