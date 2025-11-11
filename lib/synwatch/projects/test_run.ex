defmodule Synwatch.Projects.TestRun do
  use Ecto.Schema
  import Ecto.Changeset

  alias Synwatch.Projects.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_runs" do
    # TODO: Add to global ENUM
    field :status, Ecto.Enum,
      values: [:queued, :running, :passed, :failed, :errored],
      default: :queued

    # TODO: Add to global ENUM
    field :trigger, Ecto.Enum,
      values: [:manual],
      default: :manual

    field :started_at, :utc_datetime
    field :finished_at, :utc_datetime
    field :duration_ms, :integer

    # TODO: Add to global ENUM
    field :request_method, Ecto.Enum,
      values: [:GET, :POST, :PUT, :PATCH, :DELETE, :HEAD, :OPTIONS]

    field :request_url, :string
    field :request_headers, :map, default: %{}
    field :request_params, :map, default: %{}
    field :request_body, :map, default: %{}

    field :response_status, :integer
    field :response_headers, :map, default: %{}
    field :response_body, :map, default: %{}

    field :error_type, :string
    field :error_message, :string

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end

  def changeset(run, attrs) do
    run
    |> cast(attrs, [
      :test_id,
      :status,
      :trigger,
      :started_at,
      :finished_at,
      :duration_ms,
      :request_method,
      :request_url,
      :request_headers,
      :request_params,
      :request_body,
      :response_status,
      :response_headers,
      :response_body,
      :error_type,
      :error_message
    ])
    |> validate_required([:test_id, :status])
    |> validate_number(:response_status,
      greater_than_or_equal_to: 100,
      less_than_or_equal_to: 599
    )
    |> validate_number(:duration_ms, greater_than_or_equal_to: 0)
    # |> validate_timestamps_order()
    |> compute_duration()
    |> foreign_key_constraint(:test_id)
  end

  defp compute_duration(
         %Ecto.Changeset{changes: %{started_at: started_at, finished_at: finished_at}} = cs
       )
       when not is_nil(started_at) and not is_nil(finished_at) do
    ms = DateTime.diff(finished_at, started_at, :millisecond)
    put_change(cs, :duration_ms, max(ms, 0))
  end

  defp compute_duration(cs), do: cs

  defp validate_timestamps_order(%Ecto.Changeset{} = cs) do
    with {:ok, started_at} <- fetch_change(cs, :started_at),
         {:ok, finished_at} <- fetch_change(cs, :finished_at),
         true <- DateTime.compare(finished_at, started_at) in [:gt, :eq] do
      cs
    else
      _ -> add_error(cs, :finished_at, "must be after or equal to started_at")
    end
  end
end
