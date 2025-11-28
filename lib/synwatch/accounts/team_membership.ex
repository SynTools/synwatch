defmodule Synwatch.Accounts.TeamMembership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "team_memberships" do
    belongs_to :team, Synwatch.Accounts.Team
    belongs_to :user, Synwatch.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:team_id, :user_id])
    |> validate_required([:team_id, :user_id])
    |> unique_constraint([:team, :user],
      name: :team_memberships_team_id_user_id_index,
      message: "already has this user as a member"
    )
  end
end
