defmodule Synwatch.Repo.Migrations.CreateTestRuns do
  use Ecto.Migration

  def change do
    create table(:test_runs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :test_id, references(:tests, type: :binary_id, on_delete: :delete_all), null: false

      add :status, :string, null: false, default: "queued"
      add :trigger, :string, null: false, default: "manual"

      add :started_at, :utc_datetime_usec
      add :finished_at, :utc_datetime_usec
      add :duration_ms, :integer

      add :request_method, :string
      add :request_url, :text
      add :request_headers, :map, null: false, default: %{}
      add :request_params, :map, null: false, default: %{}
      add :request_body, :map, null: false, default: %{}

      add :response_status, :integer
      add :response_headers, :map, null: false, default: %{}
      add :response_body, :map, null: false, default: %{}

      add :error_type, :string
      add :error_message, :text

      timestamps(type: :utc_datetime)
    end

    create index(:test_runs, [:test_id])
    create index(:test_runs, [:status])
    create index(:test_runs, [:started_at])
  end
end
