defmodule Synwatch.Projects.Project do
  use Ecto.Schema

  import Ecto.Changeset

  alias Synwatch.Accounts.User
  alias Synwatch.Projects.Endpoint

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    belongs_to :user, User

    has_many :endpoints, Endpoint, on_delete: :delete_all, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :user_id])
    |> update_change(:name, &blank_to_nil/1)
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: 1, max: 160)
    |> unique_constraint([:user_id, :name],
      name: :projects_user_id_name_index,
      message: "can only have one project with the same name"
    )
    |> foreign_key_constraint(:user_id)
  end

  defp blank_to_nil(value) when is_binary(value) do
    value = String.trim(value)

    if value == "", do: nil, else: value
  end

  defp blank_to_nil(value), do: value
end
