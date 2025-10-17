defmodule Synwatch.Repo.Migrations.AddUniqueIndexToProjectsUserIdName do
  use Ecto.Migration

  def change do
    create unique_index(:projects, [:user_id, :name], name: :projects_user_id_name_index)
  end
end
