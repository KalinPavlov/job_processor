defmodule JobProcessor.TaskTest do
  use ExUnit.Case, async: true

  alias JobProcessor.Task, as: JobTask

  test "from_map() no dependencies" do
    task_map = %{
      "name" => "task-1",
      "command" => "touch /tmp/file1"
    }

    task = %JobTask{
      name: "task-1",
      command: "touch /tmp/file1"
    }

    assert {:ok, task} == JobTask.from_map(task_map)
  end

  test "from_map() with dependencies" do
    task_map = %{
      "name" => "task-2",
      "command" => "cat /tmp/file1",
      "requires" => [
        "task-3"
      ]
    }

    task = %JobTask{
      name: "task-2",
      command: "cat /tmp/file1",
      requires: [
        "task-3"
      ]
    }

    assert {:ok, task} == JobTask.from_map(task_map)
  end

  test "from_map() invalid arguments" do
    assert {:error, msg} = JobTask.from_map(%{})
  end
end
