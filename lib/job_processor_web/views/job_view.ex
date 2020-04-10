defmodule JobProcessorWeb.JobView do
  use JobProcessorWeb, :view

  def render("job.json", params) do
    case params[:res] do
      {:ok, job} -> job
      {:error, msg} -> msg
    end
  end
end
