defmodule Synwatch.Repo.Migrations.AddUniqueOwnerNameIndexToTeams do
  use Ecto.Migration

  def change do
    create unique_index(
             :teams,
             [:owner_id, :name],
             name: :teams_owner_id_name_index
           )
  end
end
