defmodule SynwatchWeb.Components.Environment.SwEnvironmentSelector do
  use Phoenix.Component

  attr :environments, :list, required: true
  attr :active_environment_id, :string, default: nil
  attr :action, :string, required: true
  attr :label, :string, default: nil
  attr :class, :string, default: nil

  def sw_environment_selector(assigns) do
    ~H"""
    <.form
      for={%{}}
      action={@action}
      method="post"
      class={["flex items-center", @class]}
    >
      <div class="fieldset mb-0 min-w-[12rem]">
        <select
          name="environment[environment_id]"
          class="select w-full"
          onchange="this.form.requestSubmit()"
        >
          <%= for env <- @environments do %>
            <option value={env.id} selected={env.id == @active_environment_id}>
              {env.name}
            </option>
          <% end %>
        </select>
      </div>
    </.form>
    """
  end
end
