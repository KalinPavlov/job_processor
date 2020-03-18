defmodule JobProcessor.Job do
  @typedoc """
  Represents job of tasks.
  """

  alias JobProcessor.Task, as: JobTask
  alias JobProcessor.TopSort

  use TypedStruct

  typedstruct do
    field(:tasks, list(JobTask.t()), default: [])
    field(:top_sorted, boolean, default: false)
  end

  @doc """
  Runs the top sort algorithm and sets the :top_sorted field to true
  """
  @spec order_tasks(__MODULE__.t()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def order_tasks(%__MODULE__{} = job) do
    case TopSort.sort(job.tasks) do
      {:ok, tasks} -> {:ok, %{job | tasks: tasks, top_sorted: true}}
      err -> err
    end
  end

  def order_tasks(param) do
    {:error, "Invalid argument: #{inspect(param, pretty: true)}"}
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
      {:ok, tasks} -> {:ok, struct(__MODULE__, %{tasks: tasks})}
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

  def test_data do
    %{
      tasks: [
        %{
          name: "task-1",
          command: "touch /tmp/file1"
        },
        %{
          name: "task-2",
          command: "cat /tmp/file1",
          requires: [
            "task-3"
          ]
        },
        %{
          name: "task-3",
          command: "echo 'Hello World!' > /tmp/file1",
          requires: [
            "task-1"
          ]
        },
        %{
          name: "task-4",
          command: "rm /tmp/file1",
          requires: [
            "task-2",
            "task-3"
          ]
        }
      ]
    }
  end

  def test_data1 do
    %{
      "name" => "task-4",
      "command" => "rm /tmp/file1",
      "requires" => [
        "task-2",
        "task-3"
      ]
    }
  end
end
