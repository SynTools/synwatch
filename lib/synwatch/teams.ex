defmodule Synwatch.Teams do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.Team
  alias Synwatch.Accounts.TeamMembership

  def get_all_for_user(user_id) do
    from(t in Team,
      join: tm in "team_memberships",
      on: tm.team_id == t.id,
      where: tm.user_id == type(^user_id, :binary_id),
      preload: [:members, :owner]
    )
    |> Repo.all()
  end

  def create_for_user(user_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "owner_id", user_id)

    Repo.transaction(fn ->
      case Repo.insert(Team.changeset(%Team{}, attrs)) do
        {:ok, team} ->
          membership =
            %TeamMembership{}
            |> TeamMembership.changeset(%{
              team_id: team.id,
              user_id: user_id
            })

          case Repo.insert(membership) do
            {:ok, _m} ->
              team

            {:error, changeset} ->
              Repo.rollback({:membership_error, changeset})
          end

        {:error, changeset} ->
          Repo.rollback({:team_error, changeset})
      end
    end)
    |> case do
      {:ok, team} ->
        {:ok, team}

      {:error, {:team_error, changeset}} ->
        {:error, changeset}

      {:error, {:membership_error, changeset}} ->
        {:error, changeset}
    end
  end
end
