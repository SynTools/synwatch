defmodule SynwatchWeb.Components.Environment.SwEnvironmentSelector do
  use Phoenix.Component

  alias SynwatchWeb.CoreComponents, as: CC

  attr :environments, :list, required: true
  attr :active_environment_id, :string, default: nil
  attr :class, :string, default: nil

  def sw_environment_selector(assigns) do
    form =
      Phoenix.Component.to_form(
        %{"environment_id" => assigns.active_environment_id},
        as: :environment
      )

    assigns = assign(assigns, :form, form)

    ~H"""
    <div class={["min-w-[12rem]", @class]}>
      <CC.input
        type="select"
        field={@form[:environment_id]}
        options={
          for env <- @environments do
            {env.name, env.id}
          end
        }
        prompt="Select environment"
      />
    </div>
    """
  end
end
