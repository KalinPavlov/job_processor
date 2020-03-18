defmodule JobProcessorWeb.JobController do
  use JobProcessorWeb, :controller

  alias JobProcessor.JobWorker

  def list_jobs(conn, _params) do
    json(conn, JobWorker.list_jobs())
  end

  def process_job_json(conn, _params) do
    json(conn, JobWorker.process_job(conn.params, :json))
  end

  def process_job_bash(conn, _params) do
    text(conn, JobWorker.process_job(conn.params, :text))
  end
end
