defmodule SynwatchWeb.Router do
  use SynwatchWeb, :router

  alias SynwatchWeb.Plugs.FetchCurrentUser

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SynwatchWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug FetchCurrentUser
    plug :put_current_path
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Ueberauth
  end

  pipeline :main_layout do
    plug :use_main_layout
  end

  scope "/", SynwatchWeb do
    pipe_through [:browser, :main_layout]

    get "/", PageController, :home
    get "/dashboard", PageController, :dashboard
    get "/projects", PageController, :projects
    get "/runs", PageController, :runs
    get "/settings", PageController, :settings

    get "/auth/login", AuthController, :login
    delete "/auth/logout", AuthController, :logout
  end

  scope "/auth", SynwatchWeb do
    pipe_through [:browser, :auth]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # TODO: Convert to real plug
  defp use_main_layout(conn, _opts) do
    put_layout(conn, html: {SynwatchWeb.Layouts, :main})
  end

  # TODO: Convert to real plug
  defp put_current_path(conn, _opts) do
    assign(conn, :current_path, Phoenix.Controller.current_path(conn))
  end

  # Other scopes may use custom stacks.
  # scope "/api", SynwatchWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:synwatch, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SynwatchWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
