defmodule Synwatch.HttpClient do
  def request(%{method: method, url: url, headers: headers, body: body}) do
    req = Finch.build(method, url, headers, body)

    case Finch.request(req, SynwatchFinch) do
      {:ok, %Finch.Response{} = response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end
end
