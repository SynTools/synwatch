defmodule SynwatchWeb.ProjectController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Projects
  alias Synwatch.Projects.Project
  alias Synwatch.Accounts.User

  def index(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _params) do
    projects = Projects.get_all_by_user_id(user.id)

    render(conn, :index, page_title: "Projects", projects: projects)
  end

  def new(conn, _params) do
    changeset = Ecto.Changeset.change(%Project{})

    render(conn, :new, page_title: "Create Project", changeset: changeset)
  end

  def show(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"id" => id} = _params) do
    case Projects.get_by_id_and_user_id(id, user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Project not found")

      %Project{} = project ->
        changeset = Ecto.Changeset.change(project)

        render(conn, :show,
          page_title: project.name,
          project: project,
          changeset: changeset
        )
    end
  end

  def update(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project" => updates}
      ) do
    stored_project = Projects.get_by_id_and_user_id!(id, user.id)

    with {:ok, %Project{} = project} <- Projects.update(stored_project, updates) do
      conn
      |> put_flash(:info, "Project successfully updated")
      |> redirect(to: ~p"/projects/#{project.id}")
      |> halt()
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: stored_project.name,
          project: stored_project,
          changeset: changeset
        )
    end
  end

  def create(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"project" => attrs}) do
    new_project = Map.put(attrs, "user_id", user.id)

    with {:ok, %Project{} = project} <- Projects.create(new_project) do
      conn
      |> put_flash(:info, "Project successfully created")
      |> redirect(to: ~p"/projects/#{project.id}")
      |> halt()
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:new, page_title: "Create Project", changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"id" => id} = _params) do
    stored_project = Projects.get_by_id_and_user_id!(id, user.id)

    with {:ok, %Project{} = project} <- Projects.delete(stored_project) do
      conn
      |> put_flash(:info, "Project #{project.name} successfully deleted")
      |> redirect(to: ~p"/projects")
      |> halt()
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Something went wrong deleting the project")
        |> render(:show,
          page_title: stored_project.name,
          project: stored_project,
          changeset: changeset,
          tab: "endpoints"
        )
    end
  end
end
