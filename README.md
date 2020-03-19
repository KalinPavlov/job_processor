# JobProcessor

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
  
# Project structure
   - lib
     - job_processor
        - job.ex
        - job_worker.ex
        - task.ex
     - job_processor_web
        - controllers
            - job_controller.ex
        - router.ex
   - test
     - job_processor
        - job_test.exs
        - job_worker_test.exs
        - task_test.exs
     - job_processor_web
        - controllers
            - job_controller_test.exs
            
1. lib/job_processor - contains the modules representing the business logic
2. li/job_processor_web - contains the router for specifying the endpoinds and the controller for sending the request 
data to the business layer and returning the result
3. test/job_processor - contains the test modules for the Job and Task structs and the process tests.
4. test/job_processor_web/controllers - contains the API tests of the controller
# Challenge
In order to sort the job tasks by their dependencies topological sort algorithm is used. With Erlang's :digraph module
is used to represent the nodes and the relations between them. After that :digraph_utils is used to execute the top_sort
algorithm.

In order for the API call to be used to execute bash commands one of the endpoints (/api/actions/process_job_bash)
returns the ordered commands as plain text where they are separated with '&&' in order to have dependencies between 
the commands.

*Note: In order for the call to this service with curl to succeed the 'Content_Type' had to be set to 'aplication/json'
as curl is sending it as 'application/x-www-form-urlencoded'. There is a brainstorming page for this but for now the
only solution is to set header. The problem with this is that the Plug.Conn.URLENCODED doesn't decode the body as json.
The only plug that does that is Plug.Conn.JSON. To execute the service:
```
curl -H "Content-Type: application/json" -d @job.json http://localhost:4000/api/actions/process_job_bash | bash
```

#Used additional libraries
* typed_struct - https://hex.pm/packages/typed_struct - for defining struct easier
* dialyxir - https://hex.pm/packages/dialyxir - for static code analysis

# Deployment
1. The application can be built and deployed directly on a server with Erlang/Elixir installed.
2. Docker container can be built and deployed on a platform like AWS.  

# API
Endpoints:
   * /api/actions/process_job_json
        - accepts json body, returns json
            Example body:
            ```json
            {
               "tasks" :[
                    {
                       "name" : "task-1" ,
                       "command" : "touch /tmp/file1"
                    },
                    {
                       "name" : "task-2" ,
                       "command" : "cat /tmp/file1" ,
                       "requires" :[
                           "task-3"
                       ]
                    },
                    {
                       "name" : "task-3" ,
                       "command" : "echo 'Hello World!' > /tmp/file1" ,
                       "requires" :[
                           "task-1"
                       ]
                    },
                    {
                       "name" : "task-4" ,
                       "command" : "rm /tmp/file1" ,
                       "requires" :[
                           "task-2" ,
                           "task-3"
                       ]
                    }
               ]
            }
            ```
          
            Example response:
            ```json
            [
                {
                    "name" : "task-1" ,
                    "command" : "touch /tmp/file1"
                },
                {
                    "name" : "task-3" ,
                    "command" : "echo 'Hello World!' > /tmp/file1"
                },
                {
                    "name" : "task-2" ,
                    "command" : "cat /tmp/file1"
                },
                {
                    "name" : "task-4" ,
                    "command" : "rm /tmp/file1"
                }
            ]
            ```
   * /api/actions/process_job_bash
        - accepts json body returns text:
            Example body:
            Example body:
            ```json
            {
               "tasks" :[
                    {
                       "name" : "task-1" ,
                       "command" : "touch /tmp/file1"
                    },
                    {
                       "name" : "task-2" ,
                       "command" : "cat /tmp/file1" ,
                       "requires" :[
                           "task-3"
                       ]
                    },
                    {
                       "name" : "task-3" ,
                       "command" : "echo 'Hello World!' > /tmp/file1" ,
                       "requires" :[
                           "task-1"
                       ]
                    },
                    {
                       "name" : "task-4" ,
                       "command" : "rm /tmp/file1" ,
                       "requires" :[
                           "task-2" ,
                           "task-3"
                       ]
                    }
               ]
            }
            ```
          
            Example response:
            ```text
            touch /tmp/file1 && cat /tmp/file1 && echo 'Hello World!' > /tmp/file1 && rm /tmp/file1
            ```