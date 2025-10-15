defmodule SynwatchWeb.Plugs.MainLayout do
  import Phoenix.Controller, only: [put_layout: 2]

  def init(opts), do: opts

  def call(conn, opts) do
    layout = Keyword.get(opts, :layout, {SynwatchWeb.Layouts, :main})
    put_layout(conn, html: layout)
  end
end
