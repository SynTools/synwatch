defmodule Synwatch.Enums.TestRunStatus do
  @values [:queued, :running, :passed, :failed, :errored]

  def values, do: @values
end
