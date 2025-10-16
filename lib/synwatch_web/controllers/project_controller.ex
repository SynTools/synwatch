defmodule SynwatchWeb.ProjectController do
  use SynwatchWeb, :controller

  alias Synwatch.Projects
  alias Synwatch.Accounts.User

  def index(%{assigns: %{current_user: %User{} = user}} = conn, _params) do
    projects = Projects.get_all_by_user_id(user.id)

    # TODO: Render projects in template
    IO.inspect(projects)
    render(conn, :index, page_title: "Projects")
  end
end
