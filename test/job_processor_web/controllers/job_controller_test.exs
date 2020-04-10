defmodule JobProcessorWeb.JobControllerTest do
  use JobProcessorWeb.ConnCase

  setup_all do
    json = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-3"
          ]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-1"
          ]
        },
        %{
          "name" => "task-4",
          "command" => "rm /tmp/file1",
          "requires" => [
            "task-2",
            "task-3"
          ]
        }
      ]
    }

    {:ok, json: json}
  end

  test "POST /api/actions/process_job_json", %{conn: conn, json: input} do
    expected = [
      %{
        "name" => "task-1",
        "command" => "touch /tmp/file1"
      },
      %{
        "name" => "task-3",
        "command" => "echo 'Hello World!' > /tmp/file1"
      },
      %{
        "name" => "task-2",
        "command" => "cat /tmp/file1"
      },
      %{
        "name" => "task-4",
        "command" => "rm /tmp/file1"
      }
    ]

    resp =
      conn
      |> post("/api/actions/process_job_json", input)
      |> json_response(200)

    assert expected == resp
  end

  test "POST /api/actions/process_job_bash", %{conn: conn, json: input} do
    expected =
      "touch /tmp/file1 && echo 'Hello World!' > /tmp/file1 && cat /tmp/file1 && rm /tmp/file1"

    resp =
      conn
      |> post("/api/actions/process_job_bash", input)
      |> text_response(200)

    assert expected == resp
  end

  test "POST /api/actions/process_job_json no body", %{conn: conn} do
    expected = "Invalid arguments: {%{}, :json}"

    resp =
      conn
      |> post("/api/actions/process_job_json", [])
      |> json_response(200)

    assert expected == resp
  end

  test "POST /api/actions/process_job_bash no body", %{conn: conn} do
    expected = "Invalid arguments: {%{}, :bash}"

    resp =
      conn
      |> post("/api/actions/process_job_bash", [])
      |> text_response(200)

    assert expected == resp
  end

  test "POST /api/actions/process_job_json circular dependency", %{conn: conn, json: json} do
    expected = "Unsortable contains circular dependencies!"

    req_json =
      put_in(json, [Access.key("tasks"), Access.at(0), Access.key("requires")], ["task-3"])

    resp =
      conn
      |> post("/api/actions/process_job_json", req_json)
      |> json_response(200)

    assert expected == resp
  end
end
