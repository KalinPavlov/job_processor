defmodule JobProcessorWeb.JobController do
  use JobProcessorWeb, :controller

  alias JobProcessor.JobWorker

  def process_job_json(conn, _params) do
    case JobWorker.process_job(conn.params, :json) do
      {:error, msg} -> json(conn, msg)
      res -> json(conn, res)
    end
  end

  def process_job_bash(conn, _params) do
    case JobWorker.process_job(conn.params, :bash) do
      {:error, msg} -> text(conn, msg)
      res -> text(conn, res)
    end
  end
end
