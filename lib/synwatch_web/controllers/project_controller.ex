defmodule SynwatchWeb.ProjectController do
  use SynwatchWeb, :controller

  alias Synwatch.Projects
  alias Synwatch.Projects.Project
  alias Synwatch.Accounts.User

  def index(%{assigns: %{current_user: %User{} = user}} = conn, _params) do
    projects = Projects.get_all_by_user_id(user.id)

    render(conn, :index, page_title: "Projects", projects: projects)
  end

  def create(conn, _params) do
    render(conn, :create, page_title: "Create Project")
  end

  def show(%{assigns: %{current_user: %User{} = user}} = conn, %{"id" => id} = params) do
    tab = Map.get(params, "tab", "endpoints")

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
          changeset: changeset,
          tab: tab
        )
    end
  end
end
