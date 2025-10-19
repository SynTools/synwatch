defmodule SynwatchWeb.Components.Endpoint.SwEndpointForm do
  use Phoenix.Component

  alias SynwatchWeb.CoreComponents, as: CC
  alias SynwatchWeb.Components.SWButton, as: SWB
  alias SynwatchWeb.Components.SWCard, as: SWC

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :cancel_href, :string, default: nil

  def sw_endpoint_form(assigns) do
    assigns = assign(assigns, :form, to_form(assigns.changeset))

    ~H"""
    <SWC.sw_card class="mb-8 max-w-3xl">
      <:header>
        <h2 class="text-xl font-semibold">Endpoint Settings</h2>
      </:header>

      <.form
        for={@changeset}
        action={@action}
        method={@method}
        class="space-y-6"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <CC.input name="endpoint[name]" field={@form[:name]} label="Name" />

          <CC.input
            name="endpoint[method]"
            type="select"
            label="Method"
            options={~w(GET POST PUT PATCH DELETE HEAD OPTIONS)}
            field={@form[:method]}
          />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <CC.input
            name="endpoint[base_url]"
            field={@form[:base_url]}
            label="Base URL"
            placeholder="https://api.example.com"
          />
          <CC.input
            name="endpoint[path]"
            field={@form[:path]}
            label="Path"
            placeholder="/v1/users/:id"
          />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <CC.input
            name="endpoint[description]"
            field={@form[:description]}
            label="Description"
            placeholder="Fetches a user by it's id"
          />
        </div>

        <div class="flex items-center gap-2">
          <SWB.sw_button>Save</SWB.sw_button>
          <SWB.sw_button
            style="ghost"
            color="gray"
            href={@cancel_href}
          >
            Cancel
          </SWB.sw_button>
        </div>
      </.form>
    </SWC.sw_card>
    """
  end
end
