defmodule SynwatchWeb.Components.SWCard do
  use Phoenix.Component

  @doc """
  Reusable card wrapper.

  ## Attrs
    * `id` – optional DOM id
    * `class` – extra classes for card wrapper
    * `body_class` – extra classes for the body content
  ## Slots
    * `:header` – optional header section (Title, Actions)
    * `:inner_block` – Card-Body (required)
    * `:footer` – optional footer (Buttons etc.)
  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :body_class, :string, default: nil
  slot :header
  slot :inner_block, required: true
  slot :footer

  def sw_card(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "rounded-xl border border-base-300 bg-white",
        @class
      ]}
    >
      <div :if={@header != []} class="p-5 border-b border-base-300">
        {render_slot(@header)}
      </div>

      <div class={["p-5", @body_class]}>
        {render_slot(@inner_block)}
      </div>

      <div :if={@footer != []} class="p-5 border-t border-base-300">
        {render_slot(@footer)}
      </div>
    </div>
    """
  end
end
