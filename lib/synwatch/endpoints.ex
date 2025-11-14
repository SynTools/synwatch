defmodule Synwatch.Endpoints do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Projects.Endpoint
  alias Synwatch.Projects.TestRun
  alias Synwatch.Tests

  def get_one(id, project_id, user_id) do
    latest_run_query =
      from tr in TestRun,
        order_by: [desc: tr.inserted_at],
        limit: 1

    Endpoint
    |> join(:inner, [e], p in assoc(e, :project))
    |> where(
      [e, p],
      e.id == ^id and
        e.project_id == ^project_id and
        p.user_id == ^user_id
    )
    |> preload([e, p],
      project: p,
      tests: [test_runs: ^latest_run_query]
    )
    |> Repo.one()
  end

  def get_one!(id, project_id, user_id) do
    Endpoint
    |> join(:inner, [e], p in assoc(e, :project))
    |> where(
      [e, p],
      e.id == ^id and
        e.project_id == ^project_id and
        p.user_id == ^user_id
    )
    |> preload([:project, :tests])
    |> Repo.one!()
  end

  def with_latest_test_run(%Endpoint{tests: tests} = endpoint) do
    %Endpoint{endpoint | tests: Tests.map_latest_test_run(tests)}
  end

  def update(%Endpoint{} = endpoint, attrs) do
    endpoint
    |> Endpoint.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Endpoint{} = endpoint), do: Repo.delete(endpoint)

  def create(attrs \\ %{}) do
    %Endpoint{}
    |> Endpoint.changeset(attrs)
    |> Repo.insert()
  end

  def build_url(%Endpoint{} = endpoint) do
    endpoint.base_url <> endpoint.path

    # TODO: Also receive %Test{} as parameter
    # TODO: Check request params of the test and add them to url if not empty
  end
end
