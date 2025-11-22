defmodule SynwatchWeb.SettingsController do
  use SynwatchWeb, :controller

  alias Synwatch.Accounts.User
  alias Synwatch.Teams

  def index(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _params) do
    teams = Teams.get_all_for_user(user.id)

    IO.inspect(teams)

    render(conn, :index, page_title: "Settings", teams: teams)
  end
end
