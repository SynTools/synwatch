defmodule Synwatch.Variables do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.TeamMembership
  alias Synwatch.Environments.Variable

  def get_one(id, environment_id, project_id, user_id) do
    Variable
    |> join(:inner, [v], env in assoc(v, :environment))
    |> join(:inner, [v, env], p in assoc(env, :project))
    |> join(:inner, [v, env, p], t in assoc(p, :team))
    |> join(:inner, [v, env, p, t], tm in TeamMembership, on: tm.team_id == t.id)
    |> where(
      [v, env, p, _t, tm],
      v.id == ^id and
        env.id == ^environment_id and
        p.id == ^project_id and
        tm.user_id == ^user_id
    )
    |> preload([v, env, p, t, _tm],
      environment: {env, project: {p, team: t}}
    )
    |> Repo.one()
  end

  def create_for_environment(environment_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "environment_id", environment_id)

    %Variable{}
    |> Variable.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Variable{} = variable, attrs) do
    variable
    |> Variable.changeset(attrs)
    |> Repo.update()
  end
end
