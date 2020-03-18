defmodule JobProcessor.JobWorker do
  require Logger
  use GenServer

  alias JobProcessor.Job
  alias JobProcessor.TopSort

  ## Server code

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  @impl true
  def handle_call({:process_job, return_type, %{"tasks" => _tasks} = job}, _from, jobs) do
    with {:ok, job_struct} <- Job.from_map(job),
         {:ok, sorted_job} <- TopSort.sort(job_struct) do
      {:ok, result} =
        case return_type do
          :json -> Job.to_list(sorted_job)
          :text -> Job.to_bash_commands(sorted_job)
        end

      {:reply, result, [sorted_job | jobs]}
    else
      err ->
        {:reply, err, jobs}
    end
  end

  @impl true
  def handle_call({:list_jobs}, _from, jobs) do
    {:reply, jobs, jobs}
  end

  @impl true
  def handle_call(msg, _from, jobs) do
    Logger.info("No handler available for: #{inspect(msg, pretty: true)}")
    {:noreply, jobs}
  end

  ## Client Code

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Processes the job tasks and orders them topologically.

  Returns `{:ok, tasks}` if the tasks are processed correctly otherwise returns '{:error, msg}'.
  """
  @spec process_job(map, atom()) :: {:ok, list()} | {:error, String.t()}
  def process_job(%{"tasks" => _tasks} = job, return_type) when return_type in [:json, :text] do
    GenServer.call(:job_worker, {:process_job, return_type, job})
  end

  def process_job(job, return_type) do
    {:error, "Invalid arguments: #{inspect({job, return_type}, pretty: true)}"}
  end

  @doc """
  Returns list of available jobs.
  """
  @spec list_jobs() :: list()
  def list_jobs() do
    GenServer.call(:job_worker, {:list_jobs})
  end
end
