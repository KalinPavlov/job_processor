defmodule JobProcessor do
  require Logger
  alias JobProcessor.Job

  @doc """
  Processes the job tasks and orders them topologically.

  Returns `tasks` if the tasks are processed correctly otherwise returns '{:error, msg}'.
  """
  @spec process_job(map, atom()) :: {:ok, list()} | {:error, term()}
  def process_job(%{"tasks" => _tasks} = job, return_type) when return_type in [:json, :bash] do
    Logger.debug("Processing job: #{inspect({job, return_type}, pretty: true)}")

    with {:ok, job_struct} <- Job.from_map(job),
         {:ok, sorted_job} <- Job.order_tasks(job_struct) do
      process(sorted_job, return_type)
    end
  end

  def process_job(job, return_type) do
    {:error, "Invalid arguments: #{inspect({job, return_type}, pretty: true)}"}
  end

  defp process(%Job{} = job, :json) do
    Job.to_list(job)
  end

  defp process(%Job{} = job, :bash) do
    Job.to_bash_commands(job)
  end
end
