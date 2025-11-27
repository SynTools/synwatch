defmodule Synwatch.Projects do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.TeamMembership
  alias Synwatch.Projects.Project

  import Ecto.Query

  def get_all_for_user(user_id) do
    from(p in Project,
      join: t in assoc(p, :team),
      join: tm in TeamMembership,
      on: tm.team_id == t.id,
      where: tm.user_id == ^user_id,
      preload: [:team],
      order_by: [asc: p.inserted_at]
    )
    |> Repo.all()
  end

  def get_one_for_user(project_id, user_id) do
    from(p in Project,
      join: t in assoc(p, :team),
      join: tm in TeamMembership,
      on: tm.team_id == t.id,
      where: p.id == ^project_id and tm.user_id == ^user_id,
      preload: [:endpoints, :team]
    )
    |> Repo.one()
  end

  def update(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def create(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def delete(%Project{} = project), do: Repo.delete(project)
end
