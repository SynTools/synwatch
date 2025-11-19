defmodule Synwatch.Projects do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Projects.Project

  def get_all(user_id), do: Repo.all_by(Project, user_id: user_id)

  import Ecto.Query

  def get_one(id, user_id) do
    Project
    |> where([p], p.id == ^id and p.user_id == ^user_id)
    |> preload(:endpoints)
    |> Repo.one()
  end

  def get_one!(id, user_id), do: Repo.get_by!(Project, id: id, user_id: user_id)

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
