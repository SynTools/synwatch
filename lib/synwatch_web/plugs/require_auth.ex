defmodule SynwatchWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  def init(opts), do: opts

  def call(%{assigns: %{current_user: nil}} = conn, _opts) do
    conn
    |> redirect(to: "/auth/login")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
