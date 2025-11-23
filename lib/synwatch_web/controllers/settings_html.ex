defmodule SynwatchWeb.SettingsHTML do
  use SynwatchWeb, :html

  embed_templates "settings_html/*"

  def team_role_chip_class(owner_id, user_id) do
    if owner_id == user_id do
      "bg-green-100 text-green-700 border border-green-200"
    else
      "bg-blue-100 text-blue-700 border border-blue-200"
    end
  end

  def team_role_label(owner_id, user_id) do
    if owner_id == user_id, do: "Owner", else: "Member"
  end
end
