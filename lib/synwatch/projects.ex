defmodule Synwatch.Projects do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Projects.Project

  def get_all_by_user_id(user_id), do: Repo.all_by(Project, user_id: user_id)

  def get_by_id_and_user_id(id, user_id), do: Repo.get_by(Project, id: id, user_id: user_id)

  def get_by_id_and_user_id!(id, user_id), do: Repo.get_by!(Project, id: id, user_id: user_id)

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
