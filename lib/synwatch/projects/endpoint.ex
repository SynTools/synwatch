defmodule Synwatch.Projects.Endpoint do
  use Ecto.Schema

  import Ecto.Changeset

  alias Synwatch.Projects.Project

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "endpoints" do
    field :name, :string

    field :method, Ecto.Enum,
      values: [:GET, :POST, :PUT, :PATCH, :DELETE, :HEAD, :OPTIONS],
      default: :GET

    field :path, :string
    field :base_url, :string
    field :description, :string
    field :last_tested_at, :utc_datetime

    belongs_to :project, Project, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(endpoint, attrs) do
    endpoint
    |> cast(attrs, [
      :name,
      :method,
      :path,
      :base_url,
      :description,
      :last_tested_at,
      :project_id
    ])
    |> update_change(:path, &String.trim/1)
    |> update_change(:base_url, &String.trim/1)
    |> validate_required([:name, :method, :path, :base_url])
    |> validate_length(:name, min: 1, max: 160)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:project_id, :name],
      name: :endpoints_project_id_name_index,
      message: "can only have one endpoint with the same name"
    )
  end
end
