defmodule Synwatch.Environments.Environment do
  use Ecto.Schema

  import Ecto.Changeset

  alias Synwatch.Environments.Variable
  alias Synwatch.Projects.Project

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "environments" do
    field :name, :string

    belongs_to :project, Project
    has_many :variables, Variable, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  def changeset(environment, attrs) do
    environment
    |> cast(attrs, [:name, :project_id])
    |> validate_required([:name, :project_id])
    |> validate_length(:name, min: 1, max: 160)
    |> unique_constraint([:project_id, :name],
      name: :environments_project_id_name_index,
      message: "can only have one environment with the same name"
    )
    |> foreign_key_constraint(:project_id)
  end
end
