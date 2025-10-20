defmodule Synwatch.Projects.Test do
  use Ecto.Schema
  import Ecto.Changeset

  alias Synwatch.Projects.Endpoint

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :name, :string
    field :request_body, :map, default: %{}
    field :request_headers, :map, default: %{}
    field :request_params, :map, default: %{}
    field :response_http_code, :integer
    field :response_body, :map, default: %{}
    field :response_headers, :map, default: %{}

    belongs_to :endpoint, Endpoint

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test, attrs) do
    attrs =
      normalize_maps(
        attrs,
        ~w(request_body request_headers request_params response_body response_headers)a
      )

    test
    |> cast(attrs, [
      :name,
      :request_body,
      :request_headers,
      :request_params,
      :response_http_code,
      :response_body,
      :response_headers,
      :endpoint_id
    ])
    |> validate_required([:name, :response_http_code, :endpoint_id])
    |> validate_length(:name, min: 1, max: 160)
    |> validate_number(:response_http_code,
      greater_than_or_equal_to: 100,
      less_than_or_equal_to: 599
    )
    |> foreign_key_constraint(:endpoint_id)
    |> unique_constraint([:endpoint_id, :name],
      name: :tests_endpoint_id_name_index,
      message: "can only have one test with the same name"
    )
  end

  defp normalize_maps(attrs, keys) when is_map(attrs) do
    Enum.reduce(keys, attrs, fn key, acc ->
      case Map.get(acc, Atom.to_string(key)) || Map.get(acc, key) do
        "" -> Map.put(acc, key, %{})
        v when is_map(v) -> Map.put(acc, key, v)
        nil -> acc
        _ -> acc
      end
    end)
  end
end
