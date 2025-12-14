defmodule Synwatch.Projects.Test do
  use Ecto.Schema

  import Ecto.Changeset
  import Synwatch.Placeholders.Validator

  alias Synwatch.Projects.Endpoint
  alias Synwatch.Projects.TestRun

  @fields_with_variables [:name, :request_body, :request_headers, :request_params]

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
    field :last_run_at, :utc_datetime

    field :latest_test_run, :map, virtual: true

    belongs_to :endpoint, Endpoint
    has_many :test_runs, TestRun, on_delete: :delete_all, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test, attrs, variables \\ nil) do
    test
    |> cast(attrs, [
      :name,
      :request_body,
      :request_headers,
      :request_params,
      :response_http_code,
      :response_body,
      :response_headers,
      :last_run_at,
      :endpoint_id
    ])
    |> validate_required([:name, :response_http_code, :endpoint_id])
    |> validate_length(:name, min: 1, max: 160)
    |> validate_number(:response_http_code,
      greater_than_or_equal_to: 100,
      less_than_or_equal_to: 599
    )
    |> validate_variables(@fields_with_variables, variables)
    |> foreign_key_constraint(:endpoint_id)
    |> unique_constraint([:endpoint_id, :name],
      name: :tests_endpoint_id_name_index,
      message: "can only have one test with the same name"
    )
  end
end
