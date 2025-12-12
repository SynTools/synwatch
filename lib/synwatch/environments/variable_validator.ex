defmodule Synwatch.Environments.VariableValidator do
  import Ecto.Changeset

  @variable_regex ~r/\$\{\{\s*([A-Z0-9_]+)\s*\}\}/

  def validate_variables(changeset, _fields, nil), do: changeset

  def validate_variables(changeset, fields, variables) do
    known = MapSet.new(variables)

    Enum.reduce(fields, changeset, fn field, cs ->
      value = get_field(cs, field) || ""
      vars = value |> extract_variable_names()
      unknown = vars |> Enum.reject(&MapSet.member?(known, &1))

      case unknown do
        [] ->
          cs

        unknown ->
          add_error(
            cs,
            field,
            "Unknown variable: " <> Enum.join(unknown, ", ")
          )
      end
    end)
  end

  defp extract_variable_names(nil), do: []

  defp extract_variable_names(value) when is_binary(value) do
    @variable_regex
    |> Regex.scan(value, capture: :all_but_first)
    |> List.flatten()
    |> Enum.uniq()
  end
end
