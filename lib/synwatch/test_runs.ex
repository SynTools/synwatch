defmodule Synwatch.TestRuns do
  import Ecto.Query, warn: false
  alias Synwatch.Repo
  alias Synwatch.Accounts.TeamMembership
  alias Synwatch.Projects.TestRun

  def get_one(id, test_id, endpoint_id, project_id, user_id) do
    TestRun
    |> join(:inner, [r], t in assoc(r, :test))
    |> join(:inner, [_r, t], e in assoc(t, :endpoint))
    |> join(:inner, [_r, _t, e], p in assoc(e, :project))
    |> join(:inner, [_r, _t, _e, p], team in assoc(p, :team))
    |> join(:inner, [_r, _t, _e, _p, team], tm in TeamMembership, on: tm.team_id == team.id)
    |> where(
      [r, t, e, p, _team, tm],
      r.id == ^id and
        t.id == ^test_id and
        e.id == ^endpoint_id and
        p.id == ^project_id and
        tm.user_id == ^user_id
    )
    |> preload([_r, t, e, p, _team, _tm], test: {t, endpoint: {e, project: p}})
    |> Repo.one()
  end

  def create(attrs \\ %{}) do
    %TestRun{}
    |> TestRun.changeset(attrs)
    |> Repo.insert()
  end

  def create!(attrs \\ %{}) do
    %TestRun{}
    |> TestRun.changeset(attrs)
    |> Repo.insert!()
  end

  def update(%TestRun{} = test_run, attrs) do
    test_run
    |> TestRun.changeset(attrs)
    |> Repo.update()
  end

  def update!(%TestRun{} = test_run, attrs) do
    test_run
    |> TestRun.changeset(attrs)
    |> Repo.update!()
  end

  def delete(%TestRun{} = test_run), do: Repo.delete(test_run)
end
