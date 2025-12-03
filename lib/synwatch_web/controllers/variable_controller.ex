defmodule SynwatchWeb.VariableController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Environments
  alias Synwatch.Environments.Environment
  alias Synwatch.Environments.Variable
  alias Synwatch.Variables

  def create(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{
        "project_id" => project_id,
        "environment_id" => env_id,
        "variable" => attrs
      }) do
    with %Environment{} = env <- Environments.get_one(env_id, project_id, user.id),
         {:ok, %Variable{} = _variable} <- Variables.create_for_environment(env.id, attrs) do
      conn
      |> put_flash(:info, "Variable successfully created")
      |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")

      {:error, {_error, %Ecto.Changeset{} = _changeset}} ->
        conn
        |> put_flash(:error, "Failed to create variable")
        |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")

      nil ->
        conn
        |> put_status(:not_found)
        |> put_flash(:error, "Environment not found")
        |> redirect(to: ~p"/projects/#{project_id}/environments")
    end
  end
end
