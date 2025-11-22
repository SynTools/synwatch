defmodule Synwatch.Accounts.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias Synwatch.Accounts.User

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "teams" do
    field :name, :string

    belongs_to :owner, User, type: :binary_id

    many_to_many :members, User,
      join_through: "team_memberships",
      join_keys: [team_id: :id, user_id: :id]

    timestamps(type: :utc_datetime)
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :owner_id])
    |> validate_required([:name])
  end
end
