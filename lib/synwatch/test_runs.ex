defmodule Synwatch.TestRuns do
  import Ecto.Query, warn: false
  alias Synwatch.Repo
  alias Synwatch.Projects.TestRun

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
end
