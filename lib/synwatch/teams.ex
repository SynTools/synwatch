defmodule Synwatch.Teams do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Accounts.Team

  def get_all_for_user(user_id) do
    from(t in Team,
      join: tm in "team_memberships",
      on: tm.team_id == t.id,
      where: tm.user_id == type(^user_id, :binary_id),
      preload: [:members, :owner]
    )
    |> Repo.all()
  end

  def create_for_user(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end
end
