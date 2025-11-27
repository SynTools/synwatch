defmodule Synwatch.Repo.Migrations.ReplaceUserIdWithTeamIdInProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      remove :user_id
      add :team_id, references(:teams, type: :uuid, on_delete: :delete_all), null: false
    end

    create index(:projects, [:team_id])
  end
end
