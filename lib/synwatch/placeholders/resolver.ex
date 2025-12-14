defmodule Synwatch.Placeholders.Resolver do
  @placeholder_regex ~r/\$\{\{\s*(var|secret):([A-Z0-9_]+)\s*\}\}/

  @type values_map :: %{optional(String.t()) => String.t()}

  def resolve(template, vars, secrets \\ %{})
      when is_map(vars) and is_map(secrets) do
    resolve_placeholders(template, %{"var" => vars, "secret" => secrets})
  end

  def resolve_placeholders(template, sources) when is_map(sources) do
    do_resolve(template, sources)
  end

  defp do_resolve(nil, _sources), do: nil

  defp do_resolve(value, sources) when is_binary(value) do
    Regex.replace(@placeholder_regex, value, fn _full, type, name ->
      case sources do
        %{^type => map} when is_map(map) ->
          Map.get(map, name, "${{#{type}:#{name}}}")

        _ ->
          "${{#{type}:#{name}}}"
      end
    end)
  end

  defp do_resolve(value, sources) when is_map(value) do
    Map.new(value, fn {k, v} -> {k, do_resolve(v, sources)} end)
  end

  defp do_resolve(value, sources) when is_list(value) do
    Enum.map(value, &do_resolve(&1, sources))
  end

  defp do_resolve(value, _sources), do: value
end
