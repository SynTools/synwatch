defmodule SynwatchWeb.TestController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Projects.Test
  alias Synwatch.Tests

  def new(
        %Plug.Conn{assigns: %{current_user: %User{} = _user}} = conn,
        %{"project_id" => _project_id, "endpoint_id" => _endpoint_id} = _params
      ) do
    render(conn, :new, page_title: "Create Test")
  end

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id, "endpoint_id" => endpoint_id} = _params
      ) do
    case Tests.get_one(id, endpoint_id, project_id, user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:not_found,
          page_title: "Test not found",
          project_id: project_id,
          endpoint_id: endpoint_id
        )

      %Test{} = test ->
        changeset = Ecto.Changeset.change(test)

        render(conn, :show,
          page_title: test.name,
          test: test,
          changeset: changeset,
          endpoint: test.endpoint,
          project: test.endpoint.project
        )
    end
  end

  def update(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id, "endpoint_id" => endpoint_id, "test" => updates} =
          _params
      ) do
    stored_test = Tests.get_one!(id, endpoint_id, project_id, user.id)

    with {:ok, %Test{} = test} <- Tests.update(stored_test, normalize_test_params(updates)) do
      conn
      |> put_flash(:info, "Test successfully updated")
      |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{test.id}")
      |> halt()
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: stored_test.name,
          test: stored_test,
          changeset: changeset,
          endpoint: stored_test.endpoint,
          project: stored_test.endpoint.project
        )
    end
  end

  defp normalize_test_params(attrs) do
    attrs
    |> stringify_keys()
    |> put_kv_map("request_headers")
    |> put_kv_map("request_params")
    |> put_kv_map("response_headers")
    |> put_json_map("request_body_json", "request_body")
    |> put_json_map("response_body_json", "response_body")
  end

  defp stringify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {to_string(k), v} end)
    |> Enum.into(%{})
  end

  defp put_kv_map(attrs, key) do
    case Map.get(attrs, key) do
      %{} = rows ->
        normalized =
          rows
          |> Enum.sort_by(fn {idx, _} -> String.to_integer(idx) end)
          |> Enum.reduce(%{}, fn {_idx, %{"key" => k, "value" => v}}, acc ->
            k = (k || "") |> String.trim()
            v = v || ""
            if k == "", do: acc, else: Map.put(acc, k, v)
          end)

        Map.put(attrs, key, normalized)

      _ ->
        Map.put(attrs, key, %{})
    end
  end

  defp put_json_map(attrs, from_key, to_key) do
    case Map.get(attrs, from_key) do
      nil ->
        attrs

      "" ->
        Map.put(attrs, to_key, %{}) |> Map.delete(from_key)

      json when is_binary(json) ->
        case Jason.decode(json) do
          {:ok, map} when is_map(map) ->
            attrs |> Map.put(to_key, map) |> Map.delete(from_key)

          _ ->
            attrs |> Map.put(to_key, %{}) |> Map.delete(from_key)
        end
    end
  end
end
