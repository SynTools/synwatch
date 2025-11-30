defmodule SynwatchWeb.EnvironmentController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Environments
  alias Synwatch.Environments.Environment
  alias Synwatch.Projects

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "id" => id} = _params
      ) do
    with %Environment{} = environment <- Environments.get_one(id, project_id, user.id),
         projects <- Projects.get_all_for_user(user.id),
         changeset = Ecto.Changeset.change(environment) do
      render(conn, :show,
        page_title: environment.name,
        environment: environment,
        changeset: changeset,
        project: environment.project,
        projects: projects
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
        projects = Projects.get_all_for_user(user.id)

        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: environment.name,
          environment: environment,
          changeset: changeset,
          project: environment.project,
          projects: projects
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
end
