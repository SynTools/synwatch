defmodule Synwatch.Environments.VariableResolver do
  @variable_regex ~r/\$\{\{\s*(var):([A-Z0-9_]+)\s*\}\}/

  def resolve(template, vars) when is_map(vars) do
    do_resolve(template, vars)
  end

  defp do_resolve(nil, _vars), do: nil

  defp do_resolve(value, vars) when is_binary(value) do
    Regex.replace(@variable_regex, value, fn _full, _type, name ->
      Map.get(vars, name, "${{var:#{name}}}")
    end)
  end

  defp do_resolve(value, vars) when is_map(value) do
    Map.new(value, fn {k, v} -> {k, do_resolve(v, vars)} end)
  end

  defp do_resolve(value, vars) when is_list(value) do
    Enum.map(value, &do_resolve(&1, vars))
  end

  defp do_resolve(value, _vars), do: value
end
