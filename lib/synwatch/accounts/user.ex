defmodule Synwatch.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :provider, :string
    field :uid, :string
    field :email, :string
    field :name, :string
    field :avatar_url, :string
    field :access_token, :string
    field :refresh_token, :string
    field :token_expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :provider,
      :uid,
      :email,
      :name,
      :avatar_url,
      :access_token,
      :refresh_token,
      :token_expires_at
    ])
    |> validate_required([
      :provider,
      :uid,
      :email,
      :name,
      :avatar_url
    ])
  end
end
