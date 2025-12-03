defmodule Synwatch.Repo.Migrations.CreateVariables do
  use Ecto.Migration

  def change do
    create table(:variables, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :value, :string, null: false

      add :environment_id, references(:environments, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:variables, [:environment_id])

    create unique_index(
             :variables,
             [:environment_id, :name],
             name: :variables_environment_id_name_index
           )
  end
end
