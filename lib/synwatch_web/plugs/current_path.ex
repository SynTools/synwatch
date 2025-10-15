defmodule SynwatchWeb.Plugs.CurrentPath do
  import Plug.Conn
  import Phoenix.Controller, only: [current_path: 1]

  def init(opts), do: opts
  def call(conn, _opts), do: assign(conn, :current_path, current_path(conn))
end
