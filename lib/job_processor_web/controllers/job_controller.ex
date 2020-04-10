defmodule JobProcessorWeb.JobController do
  use JobProcessorWeb, :controller

  def process_job_json(conn, _params) do
    res = JobProcessor.process_job(conn.params, :json)
    render(conn, "job.json", res: res)
  end

  def process_job_bash(conn, _params) do
    case JobProcessor.process_job(conn.params, :bash) do
      {:ok, res} ->
        text(conn, res)

      {:error, msg} ->
        text(conn, msg)
    end
  end
end
