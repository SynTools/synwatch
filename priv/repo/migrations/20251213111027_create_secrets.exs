defmodule Synwatch.Repo.Migrations.CreateSecrets do
  use Ecto.Migration

  def change do
    create table(:secrets, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :value, :binary, null: false

      add :environment_id,
          references(:environments, type: :binary_id, on_delete: :delete_all),
          null: false

      timestamps()
    end

    create index(:secrets, [:environment_id])

    create unique_index(
             :secrets,
             [:environment_id, :name],
             name: :secrets_environment_id_name_index
           )
  end
end
