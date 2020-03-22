defmodule JobProcessor.JobWorker do
  require Logger
  use GenServer

  alias JobProcessor.Job

  ## Server code

  @impl true
  def init(:ok) do
    Logger.info("Starting JobWorker...")
    {:ok, []}
  end

  @impl true
  def handle_call({:process_job, return_type, %{"tasks" => _tasks} = job}, _from, state) do
    with {:ok, job_struct} <- Job.from_map(job),
         {:ok, sorted_job} <- Job.order_tasks(job_struct) do
      {:ok, result} =
        case return_type do
          :json -> Job.to_list(sorted_job)
          :bash -> Job.to_bash_commands(sorted_job)
        end

      {:reply, result, state}
    else
      err ->
        {:reply, err, state}
    end
  end

  @impl true
  def handle_call(msg, _from, state) do
    msg = "No handler available for: #{inspect(msg, pretty: true)}"
    {:reply, {:error, msg}, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.warn("No handler available for: #{inspect(msg, pretty: true)}")
    {:noreply, state}
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

  Returns `tasks` if the tasks are processed correctly otherwise returns '{:error, msg}'.
  """
  @spec process_job(map, atom()) :: list() | {:error, String.t()}
  def process_job(%{"tasks" => _tasks} = job, return_type) when return_type in [:json, :bash] do
    Logger.debug("Processing job: #{inspect({job, return_type}, pretty: true)}")
    GenServer.call(:job_worker, {:process_job, return_type, job})
  end

  def process_job(job, return_type) do
    {:error, "Invalid arguments: #{inspect({job, return_type}, pretty: true)}"}
  end
end
