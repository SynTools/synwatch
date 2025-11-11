defmodule Synwatch.TestRunner do
  alias Synwatch.Projects.Test
  alias Synwatch.Endpoints
  alias Synwatch.TestRuns
  alias Synwatch.HttpClient

  def run_now(%Test{} = test) do
    run = init_run!(test)
    req = build_request(test)

    run = mark_running(run)

    with {:ok, %Finch.Response{status: status}} <- HttpClient.request(req),
         :ok <- evaluate_http_status(req.expected_status, status),
         :ok <- pass!(run, status) do
      :ok
    else
      {:unexpected_status, reason, received} ->
        fail!(run, reason, received)
        :failed

      {:error, reason} ->
        errored!(run, reason)
        :error
    end
  end

  defp evaluate_http_status(expected, received) do
    if expected == received do
      :ok
    else
      {:unexpected_status, "Expected HTTP Code #{expected}. Got #{received}", received}
    end
  end

  defp init_run!(%Test{id: test_id}) do
    TestRuns.create!(%{
      test_id: test_id,
      status: :queued,
      trigger: :manual,
      started_at: DateTime.utc_now()
    })
  end

  defp pass!(run, status) do
    _ =
      TestRuns.update!(run, %{
        status: :passed,
        response_status: status,
        finished_at: DateTime.utc_now()
      })

    :ok
  end

  defp fail!(run, reason, status) do
    _ =
      TestRuns.update!(run, %{
        status: :failed,
        response_status: status,
        error_message: reason,
        finished_at: DateTime.utc_now()
      })

    :ok
  end

  defp errored!(run, reason) do
    _ =
      TestRuns.update!(run, %{
        status: :errored,
        error_message: transform_error_reason(reason),
        finished_at: DateTime.utc_now()
      })

    :ok
  end

  defp mark_running(run) do
    TestRuns.update!(run, %{status: :running})
  end

  defp build_request(%Test{} = test) do
    %{
      method: Atom.to_string(test.endpoint.method),
      url: Endpoints.build_url(test.endpoint),
      headers: normalize_headers(test.request_headers),
      body: normalize_body(test.request_body),
      expected_status: test.response_http_code
    }
  end

  defp normalize_headers(headers) do
    Enum.map(headers, fn {key, value} -> {to_string(key), to_string(value)} end)
  end

  defp normalize_body(body) do
    cond do
      is_map(body) -> Jason.encode!(body)
      is_binary(body) or is_nil(body) -> body
      true -> to_string(body)
    end
  end

  defp transform_error_reason(reason) when is_struct(reason), do: inspect(reason)
  # defp transform_error_reason(reason) when is_binary(reason), do: reason
  defp transform_error_reason(reason), do: to_string(reason)
end
