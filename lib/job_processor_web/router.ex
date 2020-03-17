defmodule JobProcessorWeb.Router do
  use JobProcessorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JobProcessorWeb do
    pipe_through :api
  end
end
