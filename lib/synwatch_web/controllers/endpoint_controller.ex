defmodule SynwatchWeb.EndpointController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Endpoints
  alias Synwatch.Projects.Endpoint
  alias Synwatch.Projects.Project
  alias Synwatch.Projects

  def new(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id} = _params
      ) do
    with %Project{} = project <- Projects.get_one_for_user(project_id, user.id),
         changeset = Ecto.Changeset.change(%Endpoint{project_id: project_id}) do
      render(conn, :new, page_title: "Create Endpoint", changeset: changeset, project: project)
    else
      _ -> redirect(conn, to: ~p"/projects/#{project_id}")
    end
  end

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id} = _params
      ) do
    with %Endpoint{} = endpoint <- Endpoints.get_one(id, project_id, user.id),
         endpoint = Endpoints.with_latest_test_run(endpoint),
         changeset = Ecto.Changeset.change(endpoint) do
      render(conn, :show,
        page_title: endpoint.name,
        endpoint: endpoint,
        changeset: changeset,
        project: endpoint.project,
        tests: endpoint.tests
      )
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Endpoint not found", project_id: project_id)
    end
  end

  def update(
        %Plug.Conn{assigns: %{current_user: %User{id: user_id}}} = conn,
        %{"id" => id, "project_id" => project_id, "endpoint" => updates}
      ) do
    with %Endpoint{} = endpoint <- Endpoints.get_one(id, project_id, user_id),
         {:ok, %Endpoint{} = endpoint} <- Endpoints.update(endpoint, updates) do
      conn
      |> put_flash(:info, "Endpoint successfully updated")
      |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint.id}")
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Endpoint not found")

      {:error, %Ecto.Changeset{} = changeset} ->
        endpoint = changeset.data

        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: endpoint.name,
          endpoint: endpoint,
          project: endpoint.project
        )
    end
  end

  def delete(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id} = _params
      ) do
    with %Endpoint{} = endpoint <- Endpoints.get_one(id, project_id, user.id),
         {:ok, %Endpoint{} = _endpoint} <- Endpoints.delete(endpoint) do
      conn
      |> put_flash(:info, "Endpoint successfully deleted")
      |> redirect(to: ~p"/projects/#{project_id}")
      |> halt()
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong deleting the Test")
        |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{id}")
    end
  end

  def create(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "endpoint" => attrs}
      ) do
    case Projects.get_one_for_user(project_id, user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Project not found")

      %Project{} = project ->
        attrs = Map.put(attrs, "project_id", project.id)

        case Endpoints.create(attrs) do
          {:ok, %Endpoint{} = endpoint} ->
            conn
            |> put_flash(:info, "Endpoint successfully created")
            |> redirect(to: ~p"/projects/#{project.id}/endpoints/#{endpoint.id}")

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
end
