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
  
# Project
   The project is using the Phoenix Web framework. 
# Challenge

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