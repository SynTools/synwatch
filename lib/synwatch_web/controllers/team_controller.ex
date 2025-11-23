defmodule SynwatchWeb.TeamController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Accounts.Team
  alias Synwatch.Teams

  def create(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"team" => attrs}) do
    case Teams.create_for_user(user.id, attrs) do
      {:ok, %Team{} = _team} ->
        conn
        |> put_flash(:info, "Team successfully created")
        |> redirect(to: ~p"/settings")

      {:error, {_error, %Ecto.Changeset{} = changeset}} ->
        conn
        |> flash_changeset_errors(changeset)
        |> redirect(to: ~p"/settings")
    end
  end
end
