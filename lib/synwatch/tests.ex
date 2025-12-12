defmodule Synwatch.Tests do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.TeamMembership
  alias Synwatch.Projects.Test
  alias Synwatch.Variables

  def get_one(id, endpoint_id, project_id, user_id) do
    latest_run_query =
      from tr in Synwatch.Projects.TestRun,
        order_by: [desc: tr.inserted_at]

    Test
    |> join(:inner, [t], e in assoc(t, :endpoint))
    |> join(:inner, [_t, e], p in assoc(e, :project))
    |> join(:inner, [_t, _e, p], team in assoc(p, :team))
    |> join(:inner, [_t, _e, _p, team], tm in TeamMembership, on: tm.team_id == team.id)
    |> where(
      [t, e, p, _team, tm],
      t.id == ^id and
        e.id == ^endpoint_id and
        p.id == ^project_id and
        tm.user_id == ^user_id
    )
    |> preload([_t, e, p, _team, _tm], endpoint: {e, project: p})
    |> preload(test_runs: ^latest_run_query)
    |> Repo.one()
  end

  def get_all(endpoint_id, project_id, user_id) do
    Test
    |> join(:inner, [t], e in assoc(t, :endpoint))
    |> join(:inner, [_t, e], p in assoc(e, :project))
    |> join(:inner, [_t, _e, p], team in assoc(p, :team))
    |> join(:inner, [_t, _e, _p, team], tm in TeamMembership, on: tm.team_id == team.id)
    |> where(
      [_t, e, p, _team, tm],
      e.id == ^endpoint_id and
        p.id == ^project_id and
        tm.user_id == ^user_id
    )
    |> preload([_t, e, p, _team, _tm], endpoint: {e, project: p})
    |> Repo.all()
  end

  def update(%Test{} = test, attrs, environment_id) do
    variables = Variables.list_for_environment(environment_id, :name_only)

    test
    |> Test.changeset(attrs, variables)
    |> Repo.update()
  end

  def delete(%Test{} = test), do: Repo.delete(test)

  def create(attrs \\ %{}, environment_id) do
    variables = Variables.list_for_environment(environment_id, :name_only)

    %Test{}
    |> Test.changeset(attrs, variables)
    |> Repo.insert()
  end

  def get_latest_run!(id) do
    %Test{}
    |> Repo.get!(id)
    |> preload(:test_runs)
  end

  def map_latest_test_run(tests) when is_list(tests) do
    Enum.map(tests, fn test ->
      case test.test_runs do
        [latest | _] ->
          latest_test_run = %{
            status: latest.status,
            finished_at: latest.finished_at
          }

          %Synwatch.Projects.Test{test | latest_test_run: latest_test_run}

        _ ->
          %Synwatch.Projects.Test{test | latest_test_run: nil}
      end
    end)
  end
end
