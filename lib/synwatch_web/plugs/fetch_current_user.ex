defmodule SynwatchWeb.Plugs.FetchCurrentUser do
  import Plug.Conn

  alias Synwatch.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user =
      conn
      |> get_session(:user_id)
      |> case do
        nil -> nil
        id -> Accounts.get_user(id)
      end

    assign(conn, :current_user, current_user)
  end
end
