defmodule SynwatchWeb.TestRunController do
  use SynwatchWeb, :controller

  alias Synwatch.Accounts.User
  alias Synwatch.Projects.TestRun
  alias Synwatch.TestRuns

  def delete(
        %Plug.Conn{assigns: %{current_user: %User{} = user}} = conn,
        %{
          "test_id" => test_id,
          "project_id" => project_id,
          "endpoint_id" => endpoint_id,
          "id" => id
        }
      ) do
    with %TestRun{} = run <- TestRuns.get_one(id, test_id, endpoint_id, project_id, user.id),
         {:ok, _run} <- TestRuns.delete(run) do
      conn
      |> put_flash(:info, "Test Run successfully deleted")
      |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{test_id}")
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong deleting the Test Run")
        |> redirect(to: ~p"/projects/#{project_id}/endpoints/#{endpoint_id}/tests/#{test_id}")
    end
  end
end
