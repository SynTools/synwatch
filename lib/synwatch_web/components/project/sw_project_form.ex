defmodule SynwatchWeb.Components.Project.SwProjectForm do
  use Phoenix.Component

  alias SynwatchWeb.CoreComponents, as: CC
  alias SynwatchWeb.Components.SWButton, as: SWB
  alias SynwatchWeb.Components.SWCard, as: SWC

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :cancel_href, :string, default: nil
  attr :teams, :list, required: true

  def sw_project_form(assigns) do
    form = to_form(assigns.changeset)
    single_team? = length(assigns.teams) == 1
    selected_team_id = pick_selected_team(form, assigns.teams)

    assigns =
      assigns
      |> assign(:form, form)
      |> assign(:single_team?, single_team?)
      |> assign(:selected_team_id, selected_team_id)

    ~H"""
    <SWC.sw_card class="py-2">
      <:header>
        <h2 class="text-xl font-semibold">Project Settings</h2>
      </:header>

      <.form
        for={@form}
        action={@action}
        method={@method}
        class="space-y-6"
      >
        <div>
          <label class="text-sm font-medium block">Name*</label>
          <CC.input field={@form[:name]} required />
        </div>

        <div>
          <label class="text-sm font-medium block">Team*</label>

          <CC.input
            type="select"
            field={@form[:team_id]}
            name="project[team_id]"
            options={
              for team <- @teams do
                {team.name, team.id}
              end
            }
            prompt={if @single_team?, do: nil, else: "Select a team"}
          />

          <%= if @single_team? do %>
            <input type="hidden" name="project[team_id]" value={@selected_team_id} />
          <% end %>
        </div>

        <div class="flex items-center gap-2 mt-4">
          <SWB.sw_button>Save</SWB.sw_button>
          <SWB.sw_button style="ghost" color="gray" href={@cancel_href}>
            Cancel
          </SWB.sw_button>
        </div>
      </.form>
    </SWC.sw_card>
    """
  end

  defp pick_selected_team(form, teams) do
    cond do
      form[:team_id].value ->
        form[:team_id].value

      length(teams) == 1 ->
        List.first(teams).id

      true ->
        nil
    end
  end
end
