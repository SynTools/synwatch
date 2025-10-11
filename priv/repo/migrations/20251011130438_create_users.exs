defmodule Synwatch.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :uid, :string
      add :email, :string
      add :name, :string
      add :avatar_url, :string
      add :access_token, :text, null: true
      add :refresh_token, :text, null: true
      add :token_expires_at, :utc_datetime, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
