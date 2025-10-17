defmodule SynwatchWeb.Components.SWBreadcrumbs do
  use SynwatchWeb, :html

  @doc """
  items: list of %{label: String.t(), to: String.t() | nil}
  separator: separator sign (default: ›)
  """
  attr :items, :list, required: true
  attr :separator, :string, default: "›"

  def sw_breadcrumbs(assigns) do
    ~H"""
    <nav aria-label="Breadcrumb" class="text-sm text-gray-500 mb-4">
      <ol class="flex items-center gap-2">
        <%= for {item, idx} <- Enum.with_index(@items) do %>
          <li class="flex items-center gap-2">
            <%= if item[:to] do %>
              <.link href={item[:to]} class="hover:underline truncate max-w-[20ch]">
                {item[:label]}
              </.link>
            <% else %>
              <span class="text-gray-700 font-medium truncate max-w-[20ch]">{item[:label]}</span>
            <% end %>

            <span :if={idx < length(@items) - 1} class="select-none">{@separator}</span>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end
end
