defmodule Synwatch.Repo.Migrations.CreateEnvironments do
  use Ecto.Migration

  def change do
    create table(:environments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false

      add :project_id,
          references(:projects, type: :binary_id, on_delete: :delete_all),
          null: false

      timestamps()
    end

    create index(:environments, [:project_id])

    create unique_index(
             :environments,
             [:project_id, :name],
             name: :environments_project_id_name_index
           )
  end
end
