defmodule SynwatchWeb.Components.Project.SwProjectForm do
  use Phoenix.Component

  alias SynwatchWeb.CoreComponents, as: CC
  alias SynwatchWeb.Components.SWButton, as: SWB
  alias SynwatchWeb.Components.SWCard, as: SWC

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :cancel_href, :string, default: nil

  def sw_project_form(assigns) do
    assigns = assign(assigns, :form, to_form(assigns.changeset))

    ~H"""
    <SWC.sw_card class="mb-8 max-w-md">
      <:header>
        <h2 class="text-xl font-semibold">Project Settings</h2>
      </:header>

      <.form
        for={@changeset}
        action={@action}
        method={@method}
        class="space-y-6"
      >
        <CC.input name="project[name]" field={@form[:name]} label="Name" />
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
end
