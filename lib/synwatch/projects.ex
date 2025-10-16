defmodule Synwatch.Projects do
  import Ecto.Query, warn: false

  alias Synwatch.Repo
  alias Synwatch.Projects.Project

  def get_all_by_user_id(user_id), do: Repo.all_by(Project, user_id: user_id)
end
