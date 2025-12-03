defmodule Synwatch.Environments.Variable do
  use Ecto.Schema

  import Ecto.Changeset

  alias Synwatch.Environments.Environment

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "variables" do
    field :name, :string
    field :value, :string

    belongs_to :environment, Environment

    timestamps()
  end

  def changeset(variable, attrs) do
    variable
    |> cast(attrs, [:name, :value, :environment_id])
    |> validate_required([:name, :value, :environment_id])
    |> validate_length(:name, min: 1, max: 160)
    |> validate_length(:value, min: 1, max: 160)
    |> unique_constraint([:environment_id, :name],
      name: :variables_environment_id_name_index,
      message: "can only have one variable with the same name"
    )
    |> foreign_key_constraint(:environment_id)
  end
end
