defmodule JobProcessor.JobWorkerTest do
  use ExUnit.Case, async: true

  setup_all do
    map = %{
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

    {:ok, map: map}
  end

  test "process_job() json", context do
    map = context[:map]

    expected = [
      %{
        name: "task-1",
        command: "touch /tmp/file1"
      },
      %{
        name: "task-3",
        command: "echo 'Hello World!' > /tmp/file1"
      },
      %{
        name: "task-2",
        command: "cat /tmp/file1"
      },
      %{
        name: "task-4",
        command: "rm /tmp/file1"
      }
    ]

    assert {:ok, expected} == JobProcessor.process_job(map, :json)
  end

  test "process_job() bash", context do
    map = context[:map]

    expected =
      "touch /tmp/file1 && echo 'Hello World!' > /tmp/file1 && cat /tmp/file1 && rm /tmp/file1"

    assert {:ok, expected} == JobProcessor.process_job(map, :bash)
  end

  test "process_job() different type", context do
    map = context[:map]

    assert {:error, msg} = JobProcessor.process_job(map, :something)
  end

  test "process_job() invalid input data" do
    assert {:error, msg} = JobProcessor.process_job(1, :json)
  end
end
