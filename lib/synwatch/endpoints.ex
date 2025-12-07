defmodule Synwatch.Endpoints do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.TeamMembership
  alias Synwatch.Projects.Endpoint
  alias Synwatch.Projects.TestRun
  alias Synwatch.Tests
  alias Synwatch.Variables

  def get_one(id, project_id, user_id) do
    latest_run_query =
      from tr in TestRun,
        order_by: [desc: tr.inserted_at]

    Endpoint
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
      project: {p, team: t},
      tests: [test_runs: ^latest_run_query]
    )
    |> Repo.one()
  end

  def with_latest_test_run(%Endpoint{tests: tests} = endpoint) do
    %Endpoint{endpoint | tests: Tests.map_latest_test_run(tests)}
  end

  def update(%Endpoint{} = endpoint, attrs, environment_id) do
    variables = Variables.list_for_environment(environment_id, :name_only)

    endpoint
    |> Endpoint.changeset(attrs, variables)
    |> Repo.update()
  end

  def delete(%Endpoint{} = endpoint), do: Repo.delete(endpoint)

  def create(attrs \\ %{}, environment_id) do
    variables = Variables.list_for_environment(environment_id, :name_only)

    %Endpoint{}
    |> Endpoint.changeset(attrs, variables)
    |> Repo.insert()
  end

  def build_url(%Endpoint{} = endpoint) do
    endpoint.base_url <> endpoint.path

    # TODO: Also receive %Test{} as parameter
    # TODO: Check request params of the test and add them to url if not empty
  end
end
