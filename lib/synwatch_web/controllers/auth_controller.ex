defmodule SynwatchWeb.AuthController do
  use SynwatchWeb, :controller

  alias Ueberauth.Auth
  alias Synwatch.Accounts

  plug Ueberauth when action in [:request, :callback]

  def login(conn, _params), do: render(conn, :login)

  def request(conn, _params), do: redirect(conn, to: ~p"/auth/login")

  def callback(%{assigns: %{ueberauth_auth: %Auth{} = auth}} = conn, _params) do
    # TODO: Check provider in "params" and add as parameter to upsert_github_user
    case Accounts.upsert_github_user(auth) do
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
