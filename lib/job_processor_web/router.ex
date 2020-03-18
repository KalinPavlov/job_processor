defmodule JobProcessorWeb.Router do
  use JobProcessorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug Plug.Parsers,
      parsers: [:json],
      pass: ["text/*", "application/x-www-form-urlencoded"],
      json_decoder: Jason
  end

  scope "/api/actions", JobProcessorWeb do
    pipe_through :api

    post "/process_job_json", JobController, :process_job_json
    post "/process_job_bash", JobController, :process_job_bash
  end
end
