defmodule SynwatchWeb.Components.Test.SwTestForm do
  use Phoenix.Component
  alias SynwatchWeb.CoreComponents, as: CC
  alias SynwatchWeb.Components.SWButton, as: SWB
  alias SynwatchWeb.Components.SWCard, as: SWC

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :cancel_href, :string, default: nil

  def sw_test_form(assigns) do
    assigns = assign(assigns, :form, to_form(assigns.changeset))

    ~H"""
    <.form for={@form} action={@action} method={@method} class="space-y-6">
      <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 items-start">
        <SWC.sw_card class="h-full">
          <:header>
            <h2 class="text-xl font-semibold">Test Settings</h2>
          </:header>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <CC.input field={@form[:name]} label="Name" />
          </div>
        </SWC.sw_card>

        <SWC.sw_card class="h-full">
          <:header>
            <h2 class="text-xl font-semibold">Request</h2>
          </:header>

          <div>
            <label class="text-sm font-medium mb-2 block">Headers</label>

            <div class="space-y-2" data-kv-group="request_headers">
              <%= for {idx, k, v} <- kv_rows_indexed(@form[:request_headers].value) do %>
                <div class="grid grid-cols-[1fr_1fr_auto] gap-2 items-start" data-kv-row>
                  <input
                    name={"test[request_headers][#{idx}][key]"}
                    value={k}
                    placeholder="Key"
                    class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                  <input
                    name={"test[request_headers][#{idx}][value]"}
                    value={v}
                    placeholder="Value"
                    class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                  <button
                    type="button"
                    data-kv-remove
                    class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
                  >
                    -
                  </button>
                </div>
              <% end %>
            </div>

            <div class="mt-3">
              <button
                type="button"
                data-kv-add="request_headers"
                class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
              >
                +
              </button>
            </div>

            <template data-kv-template="request_headers">
              <div class="grid grid-cols-[1fr_1fr_auto] gap-2 items-start" data-kv-row>
                <input
                  name="test[request_headers][__INDEX__][key]"
                  placeholder="Key"
                  class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
                <input
                  name="test[request_headers][__INDEX__][value]"
                  placeholder="Value"
                  class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
                <button
                  type="button"
                  data-kv-remove
                  class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
                >
                  -
                </button>
              </div>
            </template>
          </div>

          <div class="mt-6">
            <label class="text-sm font-medium mb-2 block">Query Params</label>

            <div class="space-y-2" data-kv-group="request_params">
              <%= for {idx, k, v} <- kv_rows_indexed(@form[:request_params].value) do %>
                <div class="grid grid-cols-[1fr_1fr_auto] gap-2 items-start" data-kv-row>
                  <input
                    name={"test[request_params][#{idx}][key]"}
                    value={k}
                    placeholder="Key"
                    class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                  <input
                    name={"test[request_params][#{idx}][value]"}
                    value={v}
                    placeholder="Value"
                    class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                  <button
                    type="button"
                    data-kv-remove
                    class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
                  >
                    -
                  </button>
                </div>
              <% end %>
            </div>

            <div class="mt-3">
              <button
                type="button"
                data-kv-add="request_params"
                class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
              >
                +
              </button>
            </div>

            <template data-kv-template="request_params">
              <div class="grid grid-cols-[1fr_1fr_auto] gap-2 items-start" data-kv-row>
                <input
                  name="test[request_params][__INDEX__][key]"
                  placeholder="Key"
                  class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
                <input
                  name="test[request_params][__INDEX__][value]"
                  placeholder="Value"
                  class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
                <button
                  type="button"
                  data-kv-remove
                  class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
                >
                  -
                </button>
              </div>
            </template>
          </div>

          <div class="mt-6">
            <label class="text-sm font-medium mb-2 block">Request Body (JSON)</label>
            <CC.input
              name="test[request_body_json]"
              type="textarea"
              value={pretty_json(@form[:request_body].value)}
              class="input-code"
            />
          </div>
        </SWC.sw_card>

        <SWC.sw_card class="h-full">
          <:header>
            <h2 class="text-xl font-semibold">Response</h2>
          </:header>

          <div>
            <label class="text-sm font-medium mb-2 block">Headers</label>

            <div class="space-y-2" data-kv-group="response_headers">
              <%= for {idx, k, v} <- kv_rows_indexed(@form[:response_headers].value) do %>
                <div class="grid grid-cols-[1fr_1fr_auto] gap-2 items-start" data-kv-row>
                  <input
                    name={"test[response_headers][#{idx}][key]"}
                    value={k}
                    placeholder="Key"
                    class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                  <input
                    name={"test[response_headers][#{idx}][value]"}
                    value={v}
                    placeholder="Value"
                    class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                  <button
                    type="button"
                    data-kv-remove
                    class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
                  >
                    -
                  </button>
                </div>
              <% end %>
            </div>

            <div class="mt-3">
              <button
                type="button"
                data-kv-add="response_headers"
                class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
              >
                +
              </button>
            </div>

            <template data-kv-template="response_headers">
              <div class="grid grid-cols-[1fr_1fr_auto] gap-2 items-start" data-kv-row>
                <input
                  name="test[response_headers][__INDEX__][key]"
                  placeholder="Key"
                  class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
                <input
                  name="test[response_headers][__INDEX__][value]"
                  placeholder="Value"
                  class="rounded-lg border border-base-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
                <button
                  type="button"
                  data-kv-remove
                  class="px-3 py-2 text-sm rounded-lg border border-base-300 hover:bg-gray-50"
                >
                  -
                </button>
              </div>
            </template>
          </div>

          <div class="mt-6">
            <label class="text-sm font-medium block">HTTP Status</label>
            <CC.input field={@form[:response_http_code]} type="number" />
          </div>

          <div class="mt-6">
            <label class="text-sm font-medium mb-2 block">Body (JSON)</label>
            <CC.input
              name="test[response_body_json]"
              type="textarea"
              value={pretty_json(@form[:response_body].value)}
              class="input-code"
            />
          </div>
        </SWC.sw_card>
      </div>

      <div class="flex items-center gap-2">
        <SWB.sw_button>Save</SWB.sw_button>
        <SWB.sw_button style="ghost" color="gray" href={@cancel_href}>Cancel</SWB.sw_button>
      </div>
    </.form>
    """
  end

  defp kv_rows_indexed(nil), do: []
  defp kv_rows_indexed(map) when map == %{}, do: []

  defp kv_rows_indexed(map) when is_map(map) do
    map |> Enum.with_index() |> Enum.map(fn {{k, v}, idx} -> {idx, k, v} end)
  end

  defp pretty_json(nil), do: ""
  defp pretty_json(map) when is_map(map), do: Jason.encode!(map, pretty: true)
  defp pretty_json(_), do: ""
end
