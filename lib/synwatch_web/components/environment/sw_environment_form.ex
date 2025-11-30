defmodule SynwatchWeb.Components.Environment.SwEnvironmentForm do
  use Phoenix.Component

  alias SynwatchWeb.CoreComponents, as: CC
  alias SynwatchWeb.Components.SWButton, as: SWB
  alias SynwatchWeb.Components.SWCard, as: SWC

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :cancel_href, :string, default: nil

  def sw_environment_form(assigns) do
    form = to_form(assigns.changeset)

    assigns =
      assigns
      |> assign(:form, form)

    ~H"""
    <SWC.sw_card class="max-w-lg">
      <:header>
        <h2 class="text-xl font-semibold">Environment Settings</h2>
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
