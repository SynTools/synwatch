defmodule SynwatchWeb.ProjectController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Projects
  alias Synwatch.Projects.Project
  alias Synwatch.Accounts.User

  def index(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _params) do
    projects = Projects.get_all(user.id)

    render(conn, :index, page_title: "Projects", projects: projects)
  end

  def new(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _params) do
    changeset = Ecto.Changeset.change(%Project{})

    render(conn, :new,
      page_title: "Create Project",
      changeset: changeset,
      teams: user.teams
    )
  end

  def show(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"id" => id} = _params) do
    with %Project{} = project <- Projects.get_one_for_user(id, user.id),
         changeset = Ecto.Changeset.change(project) do
      render(conn, :show,
        page_title: project.name,
        project: project,
        endpoints: project.endpoints,
        changeset: changeset,
        teams: user.teams
      )
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Project not found")
    end
  end

  def update(
        %Plug.Conn{assigns: %{current_user: %User{id: user_id}}} = conn,
        %{"id" => id, "project" => updates}
      ) do
    with %Project{} = project <- Projects.get_one_for_user(id, user_id),
         {:ok, %Project{} = project} <- Projects.update(project, updates) do
      conn
      |> put_flash(:info, "Project successfully updated")
      |> redirect(to: ~p"/projects/#{project.id}")
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Project not found")

      {:error, %Ecto.Changeset{} = changeset} ->
        project = changeset.data

        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: project.name,
          project: project,
          changeset: changeset
        )
    end
  end

  def create(conn, %{"project" => attrs}) do
    with team_id when not is_nil(team_id) <- Map.get(attrs, "team_id"),
         {:ok, %Project{} = project} <- Projects.create(attrs) do
      conn
      |> put_flash(:info, "Project successfully created")
      |> redirect(to: ~p"/projects/#{project.id}")
    else
      nil ->
        conn
        |> put_flash(:error, "User has to be in a team")
        |> put_status(:forbidden)
        |> redirect(to: ~p"/projects")
        |> halt()

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:new,
          page_title: "Create Project",
          changeset: changeset
        )
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"id" => id} = _params) do
    with %Project{} = project <- Projects.get_one_for_user(id, user.id),
         {:ok, %Project{} = _project} <- Projects.delete(project) do
      conn
      |> put_flash(:info, "Project successfully deleted")
      |> redirect(to: ~p"/projects")
      |> halt()
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong deleting the Project")
        |> redirect(to: ~p"/projects/#{id}")
    end
  end
end
