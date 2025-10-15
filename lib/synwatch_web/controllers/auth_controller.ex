defmodule SynwatchWeb.AuthController do
  use SynwatchWeb, :controller

  alias Ueberauth.Auth
  alias Synwatch.Accounts

  @login_page "/auth/login"
  @home_page "/"

  def login(%{assigns: %{current_user: current_user}} = conn, _params) do
    if current_user do
      redirect(conn, to: @home_page)
    else
      render(conn, :login, page_title: "Login")
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: @login_page)
  end

  def request(conn, _params), do: redirect(conn, to: @login_page)

  def callback(%{assigns: %{ueberauth_auth: %Auth{} = auth}} = conn, _params) do
    provider = auth.provider |> to_string()

    case Accounts.upsert_github_user(auth, provider) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome, #{user.name || user.email || "User"}!")
        |> redirect(to: @home_page)

      {:error, reason} ->
        IO.inspect(reason)

        conn
        |> put_flash(:error, "Github login failed")
        |> redirect(to: @login_page)
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    IO.inspect(failure)

    conn
    |> put_flash(:error, "Github login canceled")
    |> redirect(to: @login_page)
  end
end
