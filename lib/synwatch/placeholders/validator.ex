defmodule Synwatch.Placeholders.Validator do
  import Ecto.Changeset

  @placeholder_regex ~r/\$\{\{\s*(var|secret):([A-Z0-9_]+)\s*\}\}/

  def validate_variables(changeset, fields, variables) do
    validate_placeholders(changeset, fields, variables, type: :var, label: "variable")
  end

  def validate_secrets(changeset, fields, secrets) do
    validate_placeholders(changeset, fields, secrets, type: :secret, label: "secret")
  end

  def validate_placeholders(changeset, _fields, nil, _opts), do: changeset

  def validate_placeholders(changeset, fields, known_names, opts) when is_list(fields) do
    type = Keyword.fetch!(opts, :type) |> to_string()
    label = Keyword.get(opts, :label, type)
    known = MapSet.new(known_names || [])

    Enum.reduce(fields, changeset, fn field, cs ->
      value = get_field(cs, field)

      names = extract_names_any(value, type)

      unknown =
        names
        |> Enum.reject(&MapSet.member?(known, &1))

      case unknown do
        [] ->
          cs

        unknown ->
          add_error(cs, field, unknown_message(label, unknown))
      end
    end)
  end

  defp extract_names_any(nil, _type), do: []

  defp extract_names_any(value, type) when is_binary(value),
    do: extract_names_from_string(value, type)

  defp extract_names_any(value, type) when is_map(value) do
    value
    |> Map.values()
    |> Enum.flat_map(&extract_names_any(&1, type))
    |> Enum.uniq()
  end

  defp extract_names_any(value, type) when is_list(value) do
    value
    |> Enum.flat_map(&extract_names_any(&1, type))
    |> Enum.uniq()
  end

  defp extract_names_any(_value, _type), do: []

  defp extract_names_from_string(value, type) do
    @placeholder_regex
    |> Regex.scan(value)
    |> Enum.flat_map(fn
      [_full, ^type, name] -> [name]
      _other -> []
    end)
    |> Enum.uniq()
  end

  defp unknown_message(label, unknown) do
    case unknown do
      [one] -> "Unknown #{label}: " <> one
      many -> "Unknown #{label}s: " <> Enum.join(many, ", ")
    end
  end
end
