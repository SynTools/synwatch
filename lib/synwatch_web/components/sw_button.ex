defmodule SynwatchWeb.Components.SWButton do
  use Phoenix.Component

  # API
  attr :style, :string, default: "filled", values: ~w(filled outlined ghost)
  attr :color, :string, default: "primary", values: ~w(primary gray red green amber)
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :class, :string, default: nil
  attr :loading, :boolean, default: false
  attr :disabled, :boolean, default: false

  # Link-Unterstützung (wenn eines davon gesetzt ist, rendern wir <.link/>)
  attr :href, :string, default: nil
  attr :navigate, :any, default: nil
  attr :patch, :any, default: nil
  attr :method, :string, default: nil

  # Alle restlichen globalen attrs (type, name, value, etc.)
  attr :rest, :global,
    include:
      ~w(type name value download rel target form formaction formenctype formmethod formnovalidate formtarget)

  slot :inner_block, required: true
  slot :icon, doc: "optionales Icon links"

  def sw_button(assigns) do
    assigns =
      assign(assigns,
        classes:
          btn_classes(
            assigns.style,
            assigns.color,
            assigns.size,
            assigns.loading,
            assigns.disabled,
            assigns.class
          )
      )

    ~H"""
    <%= if @href || @navigate || @patch || @method do %>
      <.link
        class={@classes}
        href={@href}
        navigate={@navigate}
        patch={@patch}
        method={@method}
        aria-busy={@loading}
        aria-disabled={@disabled}
      >
        <span class="inline-flex items-center gap-2">
          <%= if @icon != [] do %>
            <span class="shrink-0">
              {render_slot(@icon)}
            </span>
          <% end %>
          <span>{render_slot(@inner_block)}</span>
        </span>
      </.link>
    <% else %>
      <button
        class={@classes}
        disabled={@disabled || @loading}
        aria-busy={@loading}
        {@rest}
      >
        <span class="inline-flex items-center gap-2">
          <%= if @icon != [] do %>
            <span class="shrink-0">
              {render_slot(@icon)}
            </span>
          <% end %>
          <span>{render_slot(@inner_block)}</span>
        </span>
      </button>
    <% end %>
    """
  end

  # --- Helpers ---

  defp btn_classes(style, color, size, loading, disabled, extra) do
    base =
      "inline-flex items-center justify-center rounded-lg font-medium transition cursor-pointer " <>
        "focus:outline-none focus:ring-2 focus:ring-offset-1 disabled:cursor-not-allowed " <>
        if(loading, do: "opacity-70 ", else: "") <>
        if disabled, do: "opacity-50 ", else: ""

    palette =
      case {style, color} do
        {"filled", "primary"} ->
          "bg-primary text-white hover:opacity-90 focus:ring-primary/40"

        {"filled", "gray"} ->
          "bg-gray-800 text-white hover:bg-gray-700 focus:ring-gray-400/40"

        {"filled", "red"} ->
          "bg-red-600 text-white hover:bg-red-700 focus:ring-red-400/40"

        {"filled", "green"} ->
          "bg-green-600 text-white hover:bg-green-700 focus:ring-green-400/40"

        {"filled", "amber"} ->
          "bg-amber-500 text-white hover:bg-amber-600 focus:ring-amber-400/40"

        {"outlined", "primary"} ->
          "border border-primary text-primary hover:bg-primary/10 focus:ring-primary/30"

        {"outlined", "gray"} ->
          "border border-base-300 text-gray-700 hover:bg-gray-50 focus:ring-gray-300/30"

        {"outlined", "red"} ->
          "border border-red-300 text-red-700 hover:bg-red-50 focus:ring-red-300/30"

        {"outlined", "green"} ->
          "border border-green-300 text-green-700 hover:bg-green-50 focus:ring-green-300/30"

        {"outlined", "amber"} ->
          "border border-amber-300 text-amber-700 hover:bg-amber-50 focus:ring-amber-300/30"

        {"ghost", "primary"} ->
          "text-primary hover:bg-primary/10 focus:ring-primary/30"

        {"ghost", "gray"} ->
          "text-gray-700 hover:bg-gray-100 focus:ring-gray-300/30"

        {"ghost", "red"} ->
          "text-red-700 hover:bg-red-50 focus:ring-red-300/30"

        {"ghost", "green"} ->
          "text-green-700 hover:bg-green-50 focus:ring-green-300/30"

        {"ghost", "amber"} ->
          "text-amber-700 hover:bg-amber-50 focus:ring-amber-300/30"
      end

    sizing =
      case size do
        "sm" -> "px-3 py-1.5 text-sm"
        "md" -> "px-4 py-2 text-sm"
        "lg" -> "px-5 py-2.5 text-base"
      end

    [base, palette, sizing, extra]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end
end
