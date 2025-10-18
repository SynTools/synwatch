defmodule SynwatchWeb.EndpointController do
  use SynwatchWeb, :controller

  alias Synwatch.Accounts.User
  alias Synwatch.Endpoints
  alias Synwatch.Projects.Endpoint

  def new(%Plug.Conn{} = conn, _params), do: render(conn, :new, page_title: "Create Endpoint")

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id} = _params
      ) do
    case Endpoints.get_one(id, project_id, user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Endpoint not found", project_id: project_id)

      %Endpoint{} = endpoint ->
        render(conn, :show,
          page_title: endpoint.name,
          endpoint: endpoint,
          project: endpoint.project
        )
    end
  end
end
