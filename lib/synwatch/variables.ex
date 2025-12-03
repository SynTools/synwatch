defmodule Synwatch.Variables do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Environments.Variable

  def create_for_environment(environment_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "environment_id", environment_id)

    %Variable{}
    |> Variable.changeset(attrs)
    |> Repo.insert()
  end
end
