defmodule Synwatch.Repo.Migrations.CreateEndpoints do
  use Ecto.Migration

  def change do
    create table(:endpoints, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false

      add :method, :string, null: false, default: "GET"

      add :path, :string, null: false
      add :base_url, :string, null: false
      add :description, :text

      add :headers, :map, null: false, default: %{}
      add :params, :map, null: false, default: %{}
      add :request_body, :map, null: false, default: %{}

      add :last_tested_at, :utc_datetime

      add :project_id,
          references(:projects, type: :binary_id, on_delete: :delete_all),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:endpoints, [:project_id])

    create unique_index(:endpoints, [:project_id, :name], name: :endpoints_project_id_name_index)
  end
end
