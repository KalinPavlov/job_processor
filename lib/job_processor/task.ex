defmodule JobProcessor.Task do
  use TypedStruct

  typedstruct do
    field(:name, String.t(), enforce: true)
    field(:command, String.t(), enforce: true)
    field(:requires, list(String.t()), default: [])
  end

  @doc """
  Converts the task map to the internal Task struct
  """
  @spec from_map(map()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def from_map(%{"name" => _name, "command" => _command} = task) do
    mapped_task = Enum.map(task, fn {key, value} -> {String.to_atom(key), value} end)
    {:ok, struct(__MODULE__, mapped_task)}
  end

  def from_map(param) do
    {:error, "Invalid argument: #{inspect(param, pretty: true)}"}
  end
end
