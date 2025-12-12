defmodule SynwatchWeb.Helpers.SessionHelpers do
  import Plug.Conn, only: [get_session: 2, put_session: 3]

  alias Synwatch.Environments

  def get_active_environment(conn, project_id) do
    case get_session(conn, session_key(project_id)) do
      nil ->
        user_id = conn.assigns.current_user.id

        case Environments.get_all_for_project(project_id, user_id) do
          [env | _] ->
            conn
            |> put_session(session_key(project_id), env.id)

            env.id

          [] ->
            nil
        end

      env_id ->
        env_id
    end
  end

  def set_active_environment(conn, project_id, env_id) do
    put_session(conn, session_key(project_id), env_id)
  end

  defp session_key(project_id), do: "active_environment_id:#{project_id}"
end
