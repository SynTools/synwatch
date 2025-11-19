defmodule SynwatchWeb.TestController do
  use SynwatchWeb, :controller

  import SynwatchWeb.Helpers.FlashHelpers, only: [flash_changeset_errors: 2]

  alias Synwatch.Accounts.User
  alias Synwatch.Projects.Endpoint
  alias Synwatch.Projects.Project
  alias Synwatch.Projects.Test
  alias Synwatch.Endpoints
  alias Synwatch.Projects
  alias Synwatch.Tests
  alias Synwatch.TestRunner

  def new(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "endpoint_id" => endpoint_id} = _params
      ) do
    with %Project{} = project <- Projects.get_one(project_id, user.id),
         %Endpoint{} = endpoint <- Endpoints.get_one(endpoint_id, project_id, user.id),
         changeset = Ecto.Changeset.change(%Test{endpoint_id: endpoint_id}) do
      render(conn, :new,
        page_title: "Create Test",
        project: project,
        endpoint: endpoint,
        changeset: changeset
      )
    else
      _ -> redirect(conn, to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}")
    end
  end

  def show(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id, "endpoint_id" => endpoint_id} = _params
      ) do
    with %Test{} = test <- Tests.get_one(id, endpoint_id, project_id, user.id),
         changeset = Ecto.Changeset.change(test) do
      render(conn, :show,
        page_title: test.name,
        test: test,
        changeset: changeset,
        endpoint: test.endpoint,
        project: test.endpoint.project,
        runs: test.test_runs
      )
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(:not_found,
          page_title: "Test not found",
          project_id: project_id,
          endpoint_id: endpoint_id
        )
    end
  end

  def update(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{
          "id" => id,
          "project_id" => project_id,
          "endpoint_id" => endpoint_id,
          "test" => updates
        }
      ) do
    stored_test = Tests.get_one(id, endpoint_id, project_id, user.id)

    case Tests.update(stored_test, normalize_test_params(updates)) do
      {:ok, %Test{} = test} ->
        conn
        |> put_flash(:info, "Test successfully updated")
        |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{test.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:show,
          page_title: stored_test.name,
          test: stored_test,
          changeset: changeset,
          endpoint: stored_test.endpoint,
          project: stored_test.endpoint.project,
          runs: stored_test.test_runs
        )
    end
  end

  def delete(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"id" => id, "project_id" => project_id, "endpoint_id" => endpoint_id} = _params
      ) do
    with %Test{} = test <- Tests.get_one(id, endpoint_id, project_id, user.id),
         {:ok, %Test{} = _test} <- Tests.delete(test) do
      conn
      |> put_flash(:info, "Test successfully deleted")
      |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}")
      |> halt()
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong deleting the Test")
        |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{id}")
    end
  end

  def create(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "endpoint_id" => endpoint_id, "test" => attrs}
      ) do
    project = Projects.get_one!(project_id, user.id)
    endpoint = Endpoints.get_one!(endpoint_id, project_id, user.id)

    attrs = Map.put(attrs, "endpoint_id", endpoint.id)

    case Tests.create(attrs) do
      {:ok, %Test{} = test} ->
        conn
        |> put_flash(:info, "Test successfully created")
        |> redirect(to: ~p"/projects/#{project.id}/endpoints/#{endpoint.id}/tests/#{test.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> flash_changeset_errors(changeset)
        |> render(:new,
          page_title: "Create Test",
          project: project,
          endpoint: endpoint,
          changeset: changeset
        )
    end
  end

  def run(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{"project_id" => project_id, "endpoint_id" => endpoint_id, "id" => id}
      ) do
    with %Test{} = test <- Tests.get_one(id, endpoint_id, project_id, user.id),
         result <- TestRunner.run_now(test) do
      case result do
        :ok ->
          conn
          |> put_flash(:info, "Test passed")
          |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{id}")

        :failed ->
          conn
          |> put_flash(:error, "Test failed")
          |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{id}")

        :error ->
          conn
          |> put_flash(:error, "Couldn't start test")
          |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{id}")
      end
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> put_flash(:error, "Test not found")
        |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}")
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
