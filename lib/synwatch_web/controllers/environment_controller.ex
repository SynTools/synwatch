defmodule SynwatchWeb.EnvironmentController do
  use SynwatchWeb, :controller

  alias Synwatch.Accounts.User
  alias Synwatch.Environments
  alias Synwatch.Environments.Environment

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "id" => id} = _params
      ) do
    with %Environment{} = environment <- Environments.get_one(id, project_id, user.id),
         changeset = Ecto.Changeset.change(environment) do
      render(conn, :show,
        page_title: environment.name,
        environment: environment,
        changeset: changeset
      )
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(:not_found, page_title: "Environment not found", project_id: project_id)
    end
  end
end
