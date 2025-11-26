defmodule SynwatchWeb.TeamController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Accounts.Team
  alias Synwatch.Teams

  def show(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"id" => id} = _params) do
    with %Team{} = team <- Teams.get_for_user(id, user.id),
         members <- Teams.list_members_with_joined_at(team.id),
         changeset = Ecto.Changeset.change(team) do
      render(conn, :show,
        page_title: team.name,
        team: team,
        changeset: changeset,
        members: members,
        is_owner: Teams.owner?(team, user.id)
      )
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(:not_found,
          page_title: "Team not found"
        )
    end
  end

  def create(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, %{"team" => attrs}) do
    case Teams.create_for_user(user.id, attrs) do
      {:ok, %Team{} = _team} ->
        conn
        |> put_flash(:info, "Team successfully created")
        |> redirect(to: ~p"/settings")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> redirect(to: ~p"/settings")

      {:error, {_error, %Ecto.Changeset{} = _changeset}} ->
        conn
        |> put_flash(:error, "Failed to create team")
        |> redirect(to: ~p"/settings")
    end
  end

  def update(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "team" => updates}
      ) do
    with %Team{} = stored_team <- Teams.get_for_user(id, user.id),
         true <- Teams.owner?(stored_team, user.id) do
      members = Teams.list_members_with_joined_at(stored_team.id)

      case Teams.update(stored_team, updates) do
        {:ok, %Team{} = team} ->
          conn
          |> put_flash(:info, "Team successfully updated")
          |> redirect(to: ~p"/settings/teams/#{team.id}")

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> flash_changeset_errors(changeset)
          |> render(:show,
            page_title: stored_team.name,
            team: stored_team,
            changeset: changeset,
            members: members,
            is_owner: true
          )
      end
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found,
          page_title: "Team not found"
        )

      false ->
        conn
        |> put_status(:forbidden)
        |> put_flash(:error, "You are not allowed to edit this team.")
        |> redirect(to: ~p"/settings")
    end
  end
end
