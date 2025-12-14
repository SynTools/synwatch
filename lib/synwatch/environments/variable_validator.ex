defmodule Synwatch.Environments.VariableValidator do
  import Ecto.Changeset

  @variable_regex ~r/\$\{\{\s*(var):([A-Z0-9_]+)\s*\}\}/

  def validate_variables(changeset, _fields, nil), do: changeset

  def validate_variables(changeset, fields, variables) do
    known = MapSet.new(variables)

    Enum.reduce(fields, changeset, fn field, cs ->
      value = get_field(cs, field)

      vars = extract_variable_names_any(value)

      unknown =
        vars
        |> Enum.reject(&MapSet.member?(known, &1))

      case unknown do
        [] ->
          cs

        unknown ->
          add_error(cs, field, "Unknown variable: " <> Enum.join(unknown, ", "))
      end
    end)
  end

  defp extract_variable_names_any(nil), do: []

  defp extract_variable_names_any(value) when is_binary(value),
    do: extract_variable_names_from_string(value)

  defp extract_variable_names_any(value) when is_map(value) do
    value
    |> Map.values()
    |> Enum.flat_map(&extract_variable_names_any/1)
    |> Enum.uniq()
  end

  defp extract_variable_names_any(value) when is_list(value) do
    value
    |> Enum.flat_map(&extract_variable_names_any/1)
    |> Enum.uniq()
  end

  defp extract_variable_names_any(_), do: []

  defp extract_variable_names_from_string(value) do
    @variable_regex
    |> Regex.scan(value)
    |> Enum.map(fn [_full, _type, name] -> name end)
    |> Enum.uniq()
  end
end
