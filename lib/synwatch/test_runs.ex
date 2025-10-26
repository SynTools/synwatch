defmodule Synwatch.TestRuns do
  import Ecto.Query, warn: false
  alias Synwatch.Repo
  alias Synwatch.Projects.TestRun

  def create(attrs \\ %{}) do
    %TestRun{}
    |> TestRun.changeset(attrs)
    |> Repo.insert()
  end
end
