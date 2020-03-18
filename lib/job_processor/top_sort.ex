defmodule JobProcessor.TopSort do
  @moduledoc """
  Module for sorting topologically list of tasks.
  Uses Erlang's :digraph to represent the vertices and edges.
  Uses Erlang's :digraph_util to execute the algorithm
  """

  alias JobProcessor.Task, as: JobTask
  alias JobProcessor.Job

  @type job :: list(JobTask.t())

  @doc """
  Sorts the list of tasks topologically.
  """
  @spec sort(Job.t()) :: {:ok, Job.t()} | {:error, String.t()}
  def sort(%Job{tasks: tasks, top_sorted: false} = job) do
    g = :digraph.new()

    Enum.each(tasks, fn %JobTask{requires: deps} = l ->
      :digraph.add_vertex(g, l)

      deps
      |> Enum.map(fn d -> Enum.find(tasks, fn %JobTask{name: name} -> name == d end) end)
      |> Enum.each(fn d -> add_dependency(g, l, d) end)
    end)

    case :digraph_utils.topsort(g) do
      false -> {:error, "Unsortable contains circular dependencies:"}
      sorted_tasks -> {:ok, %{job | tasks: sorted_tasks, top_sorted: true}}
    end
  end

  def sort(%Job{top_sorted: true} = job) do
    {:ok, job}
  end

  def sort(param) do
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
