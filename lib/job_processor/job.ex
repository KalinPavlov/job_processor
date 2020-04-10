defmodule JobProcessor.Job do
  @typedoc """
  Represents job of tasks.
  """

  alias JobProcessor.Task, as: JobTask

  use TypedStruct

  typedstruct do
    field(:tasks, list(JobTask.t()), default: [])
    field(:top_sorted, boolean, default: false)
  end

  @doc """
  Converts the job map to the internal Job struct
  """
  @spec from_map(map()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def from_map(%{"tasks" => tasks}) do
    mapped_tasks =
      Enum.reduce_while(tasks, {:ok, []}, fn task, acc ->
        {:ok, l} = acc

        case JobTask.from_map(task) do
          {:ok, task} -> {:cont, {:ok, [task | l]}}
          {:error, msg} -> {:halt, {:error, msg}}
        end
      end)

    case mapped_tasks do
      {:ok, tasks} -> {:ok, struct(__MODULE__, %{tasks: Enum.reverse(tasks)})}
      {:error, msg} -> {:error, msg}
    end
  end

  def from_map(param) do
    {:error, "Invalid argument: #{inspect(param, pretty: true)}"}
  end

  @spec to_bash_commands(__MODULE__.t()) :: {:ok, String.t()} | {:error, String.t()}
  def to_bash_commands(%__MODULE__{tasks: tasks}) do
    joined_tasks = Enum.map_join(tasks, " && ", & &1.command)
    {:ok, joined_tasks}
  end

  def to_bash_commands(param), do: {:error, "Invalid argument: #{inspect(param, pretty: true)}"}

  @doc """
  Converts a Job struct to list of tasks.
  """
  @spec to_list(__MODULE__.t()) :: {:ok, list()} | {:error, String.t()}
  def to_list(%__MODULE__{tasks: tasks}) do
    mapped_tasks = Enum.map(tasks, fn task -> %{:name => task.name, :command => task.command} end)
    {:ok, mapped_tasks}
  end

  def to_list(param), do: {:error, "Invalid argument: #{inspect(param, pretty: true)}"}

  @doc """
  Runs the top sort algorithm and sets the :top_sorted field to true.
  """
  @spec order_tasks(__MODULE__.t()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def order_tasks(%__MODULE__{tasks: tasks, top_sorted: false} = job) do
    g = :digraph.new()

    Enum.each(tasks, fn %JobTask{requires: deps} = l ->
      :digraph.add_vertex(g, l)

      deps
      |> Enum.map(fn d -> Enum.find(tasks, fn %JobTask{name: name} -> name == d end) end)
      |> Enum.each(fn d -> add_dependency(g, l, d) end)
    end)

    case :digraph_utils.topsort(g) do
      false -> {:error, "Unsortable contains circular dependencies!"}
      sorted_tasks -> {:ok, %{job | tasks: sorted_tasks, top_sorted: true}}
    end
  end

  def order_tasks(%__MODULE__{top_sorted: true} = job) do
    {:ok, job}
  end

  def order_tasks(param) do
    {:error, "Invalid argument: #{inspect(param, pretty: true)}"}
  end

  defp add_dependency(_g, l, l), do: :ok

  defp add_dependency(g, l, d) do
    # noop if dependency already added
    :digraph.add_vertex(g, d)
    # Dependencies represented as an edge d -> l
    :digraph.add_edge(g, d, l)
  end
end
