defmodule Synwatch.Projects.Project do
  use Ecto.Schema

  import Ecto.Changeset

  alias Synwatch.Accounts.User

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: 1, max: 160)
    |> foreign_key_constraint(:user_id)
  end
end
