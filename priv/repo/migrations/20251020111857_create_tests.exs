defmodule Synwatch.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false

      add :request_body, :map, default: %{}, null: false
      add :request_headers, :map, default: %{}, null: false
      add :request_params, :map, default: %{}, null: false

      add :response_http_code, :integer, null: false
      add :response_body, :map, default: %{}, null: false
      add :response_headers, :map, default: %{}, null: false

      add :last_run_at, :utc_datetime

      add :endpoint_id, references(:endpoints, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tests, [:endpoint_id, :name], name: :tests_endpoint_id_name_index)
    create index(:tests, [:endpoint_id])
    create index(:tests, [:last_run_at])
  end
end
