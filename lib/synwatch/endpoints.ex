defmodule Synwatch.Endpoints do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Projects.Endpoint

  def get_one(id, project_id, user_id) do
    Endpoint
    |> join(:inner, [e], p in assoc(e, :project))
    |> where(
      [e, p],
      e.id == ^id and
        e.project_id == ^project_id and
        p.user_id == ^user_id
    )
    |> preload(:project)
    |> Repo.one()
  end
end
