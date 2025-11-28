defmodule SynwatchWeb.Components.SWModal do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Reusable Modal.

  ## Attrs
    * `id` – eindeutige ID (required)
    * `size` – "sm" | "md" | "lg" (default: "md")
    * `on_close` – optional JS (e.g. `JS.push("closed")`)
  ## Slots
    * `:title` – Main Title (Text/Nodes)
    * `:inner_block` – Body
    * `:actions` – Footer-Buttons (rechtsbündig)
  """
  attr :id, :string, required: true
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :on_close, :any, default: nil
  slot :title
  slot :inner_block, required: true
  slot :actions

  def sw_modal(assigns) do
    assigns =
      assign(assigns,
        panel_w:
          case assigns.size do
            "sm" -> "max-w-sm"
            "md" -> "max-w-md"
            "lg" -> "max-w-2xl"
          end
      )

    ~H"""
    <div
      id={@id}
      class="fixed inset-0 z-50 hidden opacity-0"
      phx-window-keydown={close(@id, @on_close)}
      phx-key="escape"
    >
      <div
        class="absolute inset-0 bg-black/40"
        phx-click={close(@id, @on_close)}
      >
      </div>

      <div class={
          "absolute left-1/2 top-1/2 w-[92vw] #{@panel_w} " <>
            "-translate-x-1/2 -translate-y-1/2 rounded-xl bg-white p-5 shadow-xl"
        }>
        <div class="flex items-start justify-between gap-4">
          <h3 class="text-base font-semibold">
            <%= if @title != [] do %>
              {render_slot(@title)}
            <% end %>
          </h3>
        </div>

        <div class="mt-3">
          {render_slot(@inner_block)}
        </div>

        <div :if={@actions != []} class="mt-5 flex justify-end gap-2">
          <%= for action <- @actions do %>
            {render_slot(action)}
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc "Show modal with fade-in"
  def open(id),
    do:
      JS.show(
        to: "##{id}",
        transition: {"transition-opacity duration-150", "opacity-0", "opacity-100"}
      )

  @doc "Hide modal with fade-out; runs optional on_close JS"
  def close(id, on_close \\ nil) do
    base =
      JS.hide(
        to: "##{id}",
        transition: {"transition-opacity duration-150", "opacity-100", "opacity-0"}
      )

    if on_close, do: JS.exec(base, on_close), else: base
  end
end
