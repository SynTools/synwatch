defmodule SynwatchWeb.Helpers.FlashHelpers do
  import Phoenix.Controller, only: [put_flash: 3]
  import Phoenix.Naming, only: [humanize: 1]

  alias Ecto.Changeset

  def flash_changeset_errors(%Plug.Conn{} = conn, %Changeset{} = changeset) do
    message =
      changeset
      |> Changeset.traverse_errors(&default_translate_error/1)
      |> Enum.map(fn {field, messages} -> "#{humanize(field)} #{List.first(messages)}" end)
      |> Enum.join(", ")

    put_flash(conn, :error, message)
  end

  defp default_translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
