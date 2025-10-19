defmodule SynwatchWeb.EndpointController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

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

  def update(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id, "endpoint" => updates} = _params
      ) do
    stored_endpoint = Endpoints.get_one!(id, project_id, user.id)

    with {:ok, %Endpoint{} = endpoint} <- Endpoints.update(stored_endpoint, updates) do
      conn
      |> put_flash(:info, "Endpoint successfully updated")
      |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint.id}")
      |> halt()
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: stored_endpoint.name,
          endpoint: stored_endpoint,
          project: stored_endpoint.project
        )
    end
  end
end
