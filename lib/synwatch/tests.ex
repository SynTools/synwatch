defmodule Synwatch.Tests do
  import Ecto.Query, warn: false
  alias Synwatch.Repo
  alias Synwatch.Projects.Test
  alias Synwatch.TestRuns

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
    |> preload(:test_runs)
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
    |> preload(:test_runs)
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

  def run_now(%Test{} = test) do
    test_run = %{
      test_id: test.id,
      status: :queued,
      trigger: :manual,
      started_at: DateTime.utc_now(),
      finished_at: DateTime.utc_now()
    }

    with {:ok, run} <- TestRuns.create(test_run) do
      {:ok, run}
    end
  end
end
