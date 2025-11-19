defmodule Synwatch.TestRuns do
  import Ecto.Query, warn: false
  alias Synwatch.Repo
  alias Synwatch.Projects.TestRun

  def get_one(id, test_id, endpoint_id, project_id, user_id) do
    TestRun
    |> join(:inner, [r], t in assoc(r, :test))
    |> join(:inner, [r, t], e in assoc(t, :endpoint))
    |> join(:inner, [r, t, e], p in assoc(e, :project))
    |> where(
      [r, t, e, p],
      r.id == ^id and
        t.id == ^test_id and
        e.id == ^endpoint_id and
        p.id == ^project_id and
        p.user_id == ^user_id
    )
    |> preload([_r, _t, _e, _p], test: [endpoint: [:project]])
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
