defmodule Synwatch.Projects.Project do
  use Ecto.Schema

  import Ecto.Changeset

  alias Synwatch.Accounts.Team
  alias Synwatch.Projects.Endpoint

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    belongs_to :team, Team

    has_many :endpoints, Endpoint, on_delete: :delete_all, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :team_id])
    |> update_change(:name, &blank_to_nil/1)
    |> validate_required([:name, :team_id])
    |> validate_length(:name, min: 1, max: 160)
    |> unique_constraint([:team, :name],
      name: :projects_team_id_name_index,
      message: "can only have one project with the same name"
    )
    |> foreign_key_constraint(:team_id)
  end

  defp blank_to_nil(value) when is_binary(value) do
    value = String.trim(value)

    if value == "", do: nil, else: value
  end

  defp blank_to_nil(value), do: value
end
