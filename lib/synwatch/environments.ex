defmodule Synwatch.Environments do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.TeamMembership
  alias Synwatch.Environments.Environment

  def get_one(id, project_id, user_id) do
    Environment
    |> join(:inner, [e], p in assoc(e, :project))
    |> join(:inner, [_e, p], t in assoc(p, :team))
    |> join(:inner, [_e, _p, t], tm in TeamMembership, on: tm.team_id == t.id)
    |> where(
      [e, p, _t, tm],
      e.id == ^id and
        e.project_id == ^project_id and
        tm.user_id == ^user_id
    )
    |> preload([e, p, t, _tm],
      project: {p, team: t}
    )
    |> Repo.one()
  end

  def update(%Environment{} = environment, attrs) do
    environment
    |> Environment.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Environment{} = environment), do: Repo.delete(environment)
end
