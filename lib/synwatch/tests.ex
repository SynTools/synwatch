defmodule Synwatch.Tests do
  import Ecto.Query, warn: false
  alias Synwatch.Repo
  alias Synwatch.Projects.Test

  def get_one(id, endpoint_id, project_id, user_id) do
    Test
    |> join(:inner, [t], e in assoc(t, :endpoint))
    |> join(:inner, [t, e], p in assoc(e, :project))
    |> where(
      [t, e, p],
      t.id == ^id and
        e.id == ^endpoint_id and
        p.id == ^project_id and
        p.user_id == ^user_id
    )
    |> preload([_t, _e, _p], endpoint: [:project])
    |> preload(
      test_runs: ^from(tr in Synwatch.Projects.TestRun, order_by: [desc: tr.inserted_at])
    )
    |> Repo.one()
  end

  def get_one!(id, endpoint_id, project_id, user_id) do
    Test
    |> join(:inner, [t], e in assoc(t, :endpoint))
    |> join(:inner, [t, e], p in assoc(e, :project))
    |> where(
      [t, e, p],
      t.id == ^id and
        e.id == ^endpoint_id and
        p.id == ^project_id and
        p.user_id == ^user_id
    )
    |> preload([_t, _e, _p], endpoint: [:project])
    |> preload(
      test_runs: ^from(tr in Synwatch.Projects.TestRun, order_by: [desc: tr.inserted_at])
    )
    |> Repo.one!()
  end

  def update(%Test{} = test, attrs) do
    test
    |> Test.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Test{} = test), do: Repo.delete(test)

  def create(attrs \\ %{}) do
    %Test{}
    |> Test.changeset(attrs)
    |> Repo.insert()
  end
end
