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

  def get_for_user(team_id, user_id) do
    from(t in Team,
      join: tm in "team_memberships",
      on: tm.team_id == t.id,
      where:
        t.id == type(^team_id, :binary_id) and
          tm.user_id == type(^user_id, :binary_id)
    )
    |> Repo.one()
  end

  def list_members_with_joined_at(team_id) do
    TeamMembership
    |> where([tm], tm.team_id == ^team_id)
    |> join(:inner, [tm], u in assoc(tm, :user))
    |> preload([_tm, u], user: u)
    |> order_by([tm, _u], asc: tm.inserted_at)
    |> Repo.all()
    |> Enum.map(fn tm ->
      %{
        user: tm.user,
        joined_at: tm.inserted_at
      }
    end)
  end

  def owner?(team, user_id), do: team.owner_id == user_id
end
