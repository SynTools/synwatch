defmodule SynwatchWeb.Components.Team.SwTeamForm do
  use Phoenix.Component

  alias SynwatchWeb.CoreComponents, as: CC
  alias SynwatchWeb.Components.SWButton, as: SWB
  alias SynwatchWeb.Components.SWCard, as: SWC

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :cancel_href, :string, default: nil

  def sw_team_form(assigns) do
    assigns = assign(assigns, :form, to_form(assigns.changeset))

    ~H"""
    <.form for={@form} action={@action} method={@method} class="space-y-6">
      <SWC.sw_card class="h-full">
        <:header>
          <h2 class="text-xl font-semibold">Team</h2>
        </:header>

        <div class="space-y-4">
          <div>
            <label class="text-sm font-medium block">Name*</label>
            <CC.input field={@form[:name]} required />
          </div>

          <div class="flex items-center gap-2 justify-start">
            <SWB.sw_button>
              Save
            </SWB.sw_button>

            <SWB.sw_button
              :if={@cancel_href}
              style="ghost"
              color="gray"
              href={@cancel_href}
            >
              Cancel
            </SWB.sw_button>
          </div>
        </div>
      </SWC.sw_card>
    </.form>
    """
  end
end
