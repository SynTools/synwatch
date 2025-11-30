defmodule SynwatchWeb.Components.Environment.SwEnvironmentForm do
  use Phoenix.Component

  alias SynwatchWeb.CoreComponents, as: CC
  alias SynwatchWeb.Components.SWButton, as: SWB
  alias SynwatchWeb.Components.SWCard, as: SWC

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :cancel_href, :string, default: nil
  attr :projects, :list, required: true

  def sw_environment_form(assigns) do
    form = to_form(assigns.changeset)
    single_project? = length(assigns.projects) == 1
    selected_project_id = pick_selected_project(form, assigns.projects)

    assigns =
      assigns
      |> assign(:form, form)
      |> assign(:single_project?, single_project?)
      |> assign(:selected_project_id, selected_project_id)

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

        <div>
          <label class="text-sm font-medium block">Project*</label>

          <CC.input
            type="select"
            field={@form[:project_id]}
            name="environment[project_id]"
            options={
              for project <- @projects do
                {project.name, project.id}
              end
            }
          />

          <%= if @single_project? do %>
            <input type="hidden" name="environment[project_id]" value={@selected_project_id} />
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

  defp pick_selected_project(form, projects) do
    cond do
      form[:project_id].value ->
        form[:project_id].value

      length(projects) == 1 ->
        List.first(projects).id

      true ->
        nil
    end
  end
end
