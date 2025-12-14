defmodule SynwatchWeb.SecretController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Environments
  alias Synwatch.Environments.Environment
  alias Synwatch.Environments.Secret
  alias Synwatch.Secrets

  def create(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{
        "project_id" => project_id,
        "environment_id" => env_id,
        "secret" => attrs
      }) do
    with %Environment{} = env <- Environments.get_one(env_id, project_id, user.id),
         {:ok, %Secret{} = _secret} <- Secrets.create_for_environment(env.id, attrs) do
      conn
      |> put_flash(:info, "Secret successfully created")
      |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")

      {:error, {_error, %Ecto.Changeset{} = _changeset}} ->
        conn
        |> put_flash(:error, "Failed to create Secret")
        |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")

      nil ->
        conn
        |> put_status(:not_found)
        |> put_flash(:error, "Environment not found")
        |> redirect(to: ~p"/projects/#{project_id}/environments")
    end
  end

  def update(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{
        "project_id" => project_id,
        "environment_id" => env_id,
        "id" => id,
        "secret" => attrs
      }) do
    with %Secret{} = secret <- Secrets.get_one(id, env_id, project_id, user.id),
         {:ok, %Secret{} = _variable} <- Secrets.update(secret, attrs) do
      conn
      |> put_flash(:info, "Secret successfully updated")
      |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> put_flash(:error, "Secret not found")
        |> redirect(to: ~p"/projects/#{project_id}/environments")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")
    end
  end

  def delete(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "environment_id" => env_id, "id" => id} = _params
      ) do
    with %Secret{} = secret <- Secrets.get_one(id, env_id, project_id, user.id),
         {:ok, %Secret{} = _variable} <- Secrets.delete(secret) do
      conn
      |> put_flash(:info, "Secret successfully deleted")
      |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong deleting the Secret")
        |> redirect(to: ~p"/projects/#{project_id}/environments/#{env_id}")
    end
  end
end
