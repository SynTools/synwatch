defmodule Synwatch.Secrets do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.TeamMembership
  alias Synwatch.Environments.Secret

  def get_one(id, environment_id, project_id, user_id) do
    Secret
    |> join(:inner, [s], env in assoc(s, :environment))
    |> join(:inner, [s, env], p in assoc(env, :project))
    |> join(:inner, [s, env, p], t in assoc(p, :team))
    |> join(:inner, [s, env, p, t], tm in TeamMembership, on: tm.team_id == t.id)
    |> where(
      [s, env, p, _t, tm],
      s.id == ^id and
        env.id == ^environment_id and
        p.id == ^project_id and
        tm.user_id == ^user_id
    )
    |> preload([s, env, p, t, _tm],
      environment: {env, project: {p, team: t}}
    )
    |> Repo.one()
  end

  def create_for_environment(environment_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "environment_id", environment_id)

    %Secret{}
    |> Secret.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Secret{} = secret, attrs) do
    secret
    |> Secret.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Secret{} = secret), do: Repo.delete(secret)

  def list_for_environment(environment_id, :name_only) do
    case environment_id do
      nil ->
        nil

      _ ->
        Secret
        |> where([s], s.environment_id == ^environment_id)
        |> order_by([s], asc: s.name)
        |> Repo.all()
        |> Enum.map(fn secret -> secret.name end)
    end
  end

  def list_for_environment(environment_id, :key_value_map) do
    case environment_id do
      nil ->
        nil

      _ ->
        Secret
        |> where([s], s.environment_id == ^environment_id)
        |> order_by([s], asc: s.name)
        |> Repo.all()
        |> Map.new(fn s -> {s.name, s.value} end)
    end
  end

  def list_for_environment(environment_id) do
    case environment_id do
      nil ->
        nil

      _ ->
        Secret
        |> where([s], s.environment_id == ^environment_id)
        |> order_by([s], asc: s.name)
        |> Repo.all()
    end
  end
end
