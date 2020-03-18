defmodule JobProcessor.JobTest do
  use ExUnit.Case, async: true

  alias JobProcessor.Job
  alias JobProcessor.Task, as: JobTask
  alias JobProcessor.TopSort

  setup_all do
    job = %Job{
      tasks: [
        %JobTask{
          name: "task-1",
          command: "touch /tmp/file1"
        },
        %JobTask{
          name: "task-2",
          command: "cat /tmp/file1",
          requires: [
            "task-3"
          ]
        },
        %JobTask{
          name: "task-3",
          command: "echo 'Hello World!' > /tmp/file1",
          requires: [
            "task-1"
          ]
        },
        %JobTask{
          name: "task-4",
          command: "rm /tmp/file1",
          requires: [
            "task-2",
            "task-3"
          ]
        }
      ]
    }

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

    {:ok, job: job, map: map}
  end

  test "order_tasks() top sort no errors", state do
    job = state[:job]

    [task1, task2, task3, task4] = job.tasks
    IO.puts("#{inspect(job, pretty: true)}")
    {:ok, result} = Job.order_tasks(job)
    assert %{job | tasks: [task1, task3, task2, task4], top_sorted: true} == result
  end

  test "order_tasks() circular dependency", state do
    job = state[:job]

    circ_dep_job =
      put_in(job, [Access.key(:tasks), Access.at(0), Access.key(:requires)], ["task-3"])

    assert {:error, msg} = Job.order_tasks(circ_dep_job)
  end

  test "order_tasks() already sorted job", state do
    job = state[:job]

    [task1, task2, task3, task4] = job.tasks
    sorted_job = %{job | tasks: [task1, task3, task2, task4], top_sorted: true}
    {:ok, result} = Job.order_tasks(sorted_job)
    assert sorted_job == result
  end

  test "order_tasks() invalid argument" do
    assert {:error, msg} = Job.order_tasks(%{})
  end

  test "from_map() no errors", state do
    job = state[:job]
    map = state[:map]

    {:ok, result} = Job.from_map(map)
    assert job == result
  end

  test "from_map() invalid argument", state do
    assert {:error, msg} = Job.from_map([])
  end

  test "to_bash_commands() valid data", state do
    job = state[:job]

    bash_commands =
      "touch /tmp/file1 && cat /tmp/file1 && echo 'Hello World!' > /tmp/file1 && rm /tmp/file1"

    {:ok, result} = Job.to_bash_commands(job)
    assert bash_commands == result
  end

  test "to_bash_commands() invalid argument", state do
    assert {:error, msg} = Job.to_bash_commands([])
  end

  test "to_list() valid data", state do
    job = state[:job]

    task_list = [
      %{
        name: "task-1",
        command: "touch /tmp/file1"
      },
      %{
        name: "task-2",
        command: "cat /tmp/file1"
      },
      %{
        name: "task-3",
        command: "echo 'Hello World!' > /tmp/file1"
      },
      %{
        name: "task-4",
        command: "rm /tmp/file1"
      }
    ]

    {:ok, result} = Job.to_list(job)
    assert task_list == result
  end

  test "to_list() map invalid argument", state do
    assert {:error, msg} = Job.to_list([])
  end
end
