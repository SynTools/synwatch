defmodule Synwatch.Repo do
  use Ecto.Repo,
    otp_app: :synwatch,
    adapter: Ecto.Adapters.Postgres
end
