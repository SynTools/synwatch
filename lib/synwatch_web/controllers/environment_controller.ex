defmodule SynwatchWeb.EnvironmentController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Environments
  alias Synwatch.Environments.Environment
  alias Synwatch.Projects
  alias Synwatch.Projects.Project

  def new(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id} = _params
      ) do
    with %Project{} = project <- Projects.get_one_for_user(project_id, user.id),
         changeset = Ecto.Changeset.change(%Environment{project_id: project_id}) do
      render(conn, :new,
        page_title: "Create Environment",
        changeset: changeset,
        project: project
      )
    else
      _ -> redirect(conn, to: ~p"/projects/#{project_id}")
    end
  end

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "id" => id} = _params
      ) do
    with %Environment{} = environment <- Environments.get_one(id, project_id, user.id),
         changeset = Ecto.Changeset.change(environment) do
      render(conn, :show,
        page_title: environment.name,
        environment: environment,
        changeset: changeset,
        project: environment.project,
        variables: environment.variables,
        secrets: environment.secrets
      )
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Environment not found", project_id: project_id)
    end
  end

  def update(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id, "environment" => updates}
      ) do
    with %Environment{} = environment <- Environments.get_one(id, project_id, user.id),
         {:ok, %Environment{} = environment} <- Environments.update(environment, updates) do
      conn
      |> put_flash(:info, "Environment successfully updated")
      |> redirect(to: ~p"/projects/#{project_id}/environments/#{environment.id}")
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Environment not found")

      {:error, %Ecto.Changeset{} = changeset} ->
        environment = changeset.data

        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: environment.name,
          environment: environment,
          changeset: changeset,
          project: environment.project
        )
    end
  end

  def delete(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id} = _params
      ) do
    with %Environment{} = environment <- Environments.get_one(id, project_id, user.id),
         {:ok, %Environment{} = _endpoint} <- Environments.delete(environment) do
      conn
      |> put_flash(:info, "Environment successfully deleted")
      |> redirect(to: ~p"/projects/#{project_id}")
      |> halt()
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong deleting the Environment")
        |> redirect(to: ~p"/projects/#{project_id}/environments/#{id}")
    end
  end

  def create(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "environment" => attrs}
      ) do
    case Projects.get_one_for_user(project_id, user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Project not found")

      %Project{} = project ->
        attrs = Map.put(attrs, "project_id", project.id)

        case Environments.create(attrs) do
          {:ok, %Environment{} = environment} ->
            conn
            |> put_flash(:info, "Environment successfully created")
            |> redirect(to: ~p"/projects/#{project.id}/environments/#{environment.id}")

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> flash_changeset_errors(changeset)
            |> render(:new,
              page_title: "Create Environment",
              project: project,
              changeset: changeset
            )
        end
    end
  end
end
