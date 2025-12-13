defmodule Synwatch.Repo.Migrations.AddEnvironmentIdToTestRuns do
  use Ecto.Migration

  def change do
    alter table(:test_runs) do
      add :environment_id,
          references(:environments, type: :binary_id, on_delete: :nilify_all),
          null: true
    end

    create index(:test_runs, [:environment_id])
  end
end
