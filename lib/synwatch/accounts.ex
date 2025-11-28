defmodule Synwatch.Accounts do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.User
  alias Ueberauth.Auth

  def upsert_github_user(%Auth{} = auth, provider) do
    attrs = %{
      provider: provider,
      uid: to_string(auth.uid),
      email: auth.info.email,
      name: auth.info.name || auth.info.nickname,
      avatar_url: auth.info.image,
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      token_expires_at:
        (auth.credentials.expires_at && DateTime.from_unix!(auth.credentials.expires_at)) || nil
    }

    case Repo.get_by(User, provider: provider, uid: attrs.uid) do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      %User{} = user ->
        user
        |> User.changeset(attrs)
        |> Repo.update()
    end
  end

  def get_user(id) do
    User
    |> Repo.get(id)
    |> Repo.preload(:teams)
  end

  def get_user_by_email(email) do
    User
    |> Repo.get_by(email: email)
    |> Repo.preload(:teams)
  end
end
