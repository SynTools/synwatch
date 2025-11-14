defmodule SynwatchWeb.EndpointController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Endpoints
  alias Synwatch.Projects.Endpoint
  alias Synwatch.Projects

  def new(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id} = _params
      ) do
    project = Projects.get_by_id_and_user_id!(project_id, user.id)
    changeset = Ecto.Changeset.change(%Endpoint{project_id: project_id})

    render(conn, :new, page_title: "Create Endpoint", changeset: changeset, project: project)
  end

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
        changeset = Ecto.Changeset.change(endpoint)
        endpoint = Endpoints.with_latest_test_run(endpoint)

        render(conn, :show,
          page_title: endpoint.name,
          endpoint: endpoint,
          changeset: changeset,
          project: endpoint.project,
          tests: endpoint.tests
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

  def delete(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id} = _params
      ) do
    stored_endpoint = Endpoints.get_one!(id, project_id, user.id)

    with {:ok, %Endpoint{} = _endpoint} <- Endpoints.delete(stored_endpoint) do
      conn
      |> put_flash(:info, "Endpoint successfully deleted")
      |> redirect(to: ~p"/projects/#{project_id}")
      |> halt()
    else
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong deleting the endpoint")
        |> render(:show,
          page_title: stored_endpoint.name,
          endpoint: stored_endpoint,
          project: stored_endpoint.project
        )
    end
  end

  def create(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "endpoint" => attrs}
      ) do
    project = Projects.get_by_id_and_user_id!(project_id, user.id)
    attrs = Map.put(attrs, "project_id", project.id)

    with {:ok, %Endpoint{} = endpoint} <- Endpoints.create(attrs) do
      conn
      |> put_flash(:info, "Endpoint successfully created")
      |> redirect(to: ~p"/projects/#{project.id}/endpoints/#{endpoint.id}")
      |> halt()
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:new,
          page_title: "Create Endpoint",
          project: project,
          changeset: changeset
        )
    end
  end
end
