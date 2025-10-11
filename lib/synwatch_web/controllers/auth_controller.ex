defmodule SynwatchWeb.AuthController do
  use SynwatchWeb, :controller

  alias Ueberauth.Auth
  alias Synwatch.Accounts

  def login(%{assigns: %{current_user: %_{} = _user}} = conn, _params) do
    redirect(conn, to: ~p"/")
  end

  def login(conn, _params) do
    render(conn, :login)
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/auth/login")
  end

  def request(conn, _params), do: redirect(conn, to: ~p"/auth/login")

  def callback(%{assigns: %{ueberauth_auth: %Auth{} = auth}} = conn, _params) do
    provider = auth.provider |> to_string()

    case Accounts.upsert_github_user(auth, provider) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome, #{user.name || user.email || "User"}!")
        |> redirect(to: ~p"/")

      {:error, reason} ->
        IO.inspect(reason)

        conn
        |> put_flash(:error, "Github login failed")
        |> redirect(to: ~p"/auth/login")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    IO.inspect(failure)

    conn
    |> put_flash(:error, "Github login canceled")
    |> redirect(to: ~p"/auth/login")
  end
end
