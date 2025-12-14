defmodule Synwatch.TestRunner do
  alias Synwatch.Projects.Test
  alias Synwatch.Endpoints
  alias Synwatch.Placeholders.Resolver
  alias Synwatch.TestRuns
  alias Synwatch.HttpClient
  alias Synwatch.Secrets
  alias Synwatch.Variables

  def run_now(%Test{} = test, environment_id) do
    started_at = DateTime.utc_now()

    run = init_run!(test, environment_id)
    req = build_request(test, environment_id)

    run = mark_running(run)

    with {:ok, %Finch.Response{status: status}} <- HttpClient.request(req),
         :ok <- evaluate_http_status(req.expected_status, status),
         :ok <- pass!(run, status, started_at) do
      :ok
    else
      {:unexpected_status, reason, received} ->
        fail!(run, reason, received, started_at)
        :failed

      {:error, reason} ->
        errored!(run, reason, started_at)
        :error
    end
  end

  def run_many(tests, opts \\ [], environment_id) when is_list(tests) do
    max_concurrency = Keyword.get(opts, :max_concurrency, System.schedulers_online())
    timeout = Keyword.get(opts, :timeout, :infinity)

    tests
    |> Task.async_stream(
      fn test -> run_now(test, environment_id) end,
      max_concurrency: max_concurrency,
      timeout: timeout
    )
    |> Enum.map(fn
      {:ok, result} -> result
      {:exit, reason} -> {:crash, reason}
    end)
  end

  defp evaluate_http_status(expected, received) do
    if expected == received do
      :ok
    else
      {:unexpected_status, "Expected HTTP Code #{expected}. Got #{received}", received}
    end
  end

  defp init_run!(%Test{id: test_id}, environment_id) do
    TestRuns.create!(%{
      test_id: test_id,
      status: :queued,
      trigger: :manual,
      environment_id: environment_id
    })
  end

  defp pass!(run, status, started_at) do
    _ =
      TestRuns.update!(run, %{
        status: :passed,
        response_status: status,
        started_at: started_at,
        finished_at: DateTime.utc_now()
      })

    :ok
  end

  defp fail!(run, reason, status, started_at) do
    _ =
      TestRuns.update!(run, %{
        status: :failed,
        response_status: status,
        error_message: reason,
        started_at: started_at,
        finished_at: DateTime.utc_now()
      })

    :ok
  end

  defp errored!(run, reason, started_at) do
    _ =
      TestRuns.update!(run, %{
        status: :errored,
        error_message: transform_error_reason(reason),
        started_at: started_at,
        finished_at: DateTime.utc_now()
      })

    :ok
  end

  defp mark_running(run) do
    TestRuns.update!(run, %{status: :running})
  end

  defp build_request(%Test{} = test, environment_id) do
    variables = Variables.list_for_environment(environment_id, :key_value_map)
    secrets = Secrets.list_for_environment(environment_id, :key_value_map)

    url_template = Endpoints.build_url(test.endpoint)

    resolved_url = Resolver.resolve(url_template, variables, secrets)

    resolved_headers =
      test.request_headers
      |> Resolver.resolve(variables, secrets)
      |> normalize_headers()

    resolved_body =
      test.request_body
      |> Resolver.resolve(variables, secrets)
      |> normalize_body()

    %{
      method: Atom.to_string(test.endpoint.method),
      url: resolved_url,
      headers: resolved_headers,
      body: resolved_body,
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
  defp transform_error_reason(reason), do: to_string(reason)
end
