defmodule SynwatchWeb.Router do
  use SynwatchWeb, :router

  alias SynwatchWeb.Plugs.FetchCurrentUser
  alias SynwatchWeb.Plugs.RequireAuth
  alias SynwatchWeb.Plugs.CurrentPath
  alias SynwatchWeb.Plugs.MainLayout

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SynwatchWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug FetchCurrentUser
    plug CurrentPath
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Ueberauth
  end

  pipeline :main_layout do
    plug MainLayout
  end

  pipeline :require_auth do
    plug RequireAuth
  end

  # Public routes
  scope "/", SynwatchWeb do
    pipe_through [:browser]

    get "/auth/login", AuthController, :login
  end

  # Protected routes
  scope "/", SynwatchWeb do
    pipe_through [:browser, :require_auth, :main_layout]

    get "/", PageController, :home
    get "/dashboard", PageController, :dashboard
    get "/runs", PageController, :runs
    get "/settings", PageController, :settings
  end

  scope "/auth", SynwatchWeb do
    pipe_through [:browser, :auth]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :logout
  end

  scope "/projects", SynwatchWeb do
    pipe_through [:browser, :require_auth, :main_layout]

    get "/", ProjectController, :index
    post "/", ProjectController, :create
    get "/new", ProjectController, :new
    get "/:id", ProjectController, :show
    patch "/:id", ProjectController, :update
    delete "/:id", ProjectController, :delete
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
