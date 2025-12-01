defmodule SynwatchWeb.Helpers.SessionHelpers do
  import Plug.Conn, only: [get_session: 2, put_session: 3]

  def get_active_environment(conn, project_id), do: get_session(conn, session_key(project_id))

  def set_active_environment(conn, project_id, env_id),
    do: put_session(conn, session_key(project_id), env_id)

  defp session_key(project_id), do: "active_environment_id:#{project_id}"
end
