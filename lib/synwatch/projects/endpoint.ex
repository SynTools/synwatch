defmodule Synwatch.Projects.Endpoint do
  use Ecto.Schema

  import Ecto.Changeset

  alias Synwatch.Projects.Project
  alias Synwatch.Projects.Test

  @variable_regex ~r/\$\{\{\s*([A-Z0-9_]+)\s*\}\}/
  @fields_with_variables [:name, :path, :base_url, :description]

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "endpoints" do
    field :name, :string

    # TODO: Add to global ENUM
    field :method, Ecto.Enum,
      values: [:GET, :POST, :PUT, :PATCH, :DELETE, :HEAD, :OPTIONS],
      default: :GET

    field :path, :string
    field :base_url, :string
    field :description, :string
    field :last_tested_at, :utc_datetime

    belongs_to :project, Project, type: :binary_id
    has_many :tests, Test, on_delete: :delete_all, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(endpoint, attrs, variables \\ []) do
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
    |> unique_constraint([:project_id, :name],
      name: :endpoints_project_id_name_index,
      message: "can only have one endpoint with the same name"
    )
    |> validate_variables(@fields_with_variables, variables)
    |> foreign_key_constraint(:project_id)
  end

  defp validate_variables(changeset, _fields, nil), do: changeset

  defp validate_variables(changeset, fields, variables) do
    known = MapSet.new(variables)

    Enum.reduce(fields, changeset, fn field, cs ->
      value = get_field(cs, field) || ""

      vars =
        value
        |> extract_variable_names()

      unknown =
        vars
        |> Enum.reject(&MapSet.member?(known, &1))

      case unknown do
        [] ->
          cs

        unknown ->
          add_error(
            cs,
            field,
            "Unknown variable: " <> Enum.join(unknown, ", ")
          )
      end
    end)
  end

  defp extract_variable_names(nil), do: []

  defp extract_variable_names(value) when is_binary(value) do
    @variable_regex
    |> Regex.scan(value, capture: :all_but_first)
    |> List.flatten()
    |> Enum.uniq()
  end
end
