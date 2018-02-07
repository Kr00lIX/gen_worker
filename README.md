# GenWorker

[![Build Status](https://travis-ci.org/Kr00lIX/gen_worker.svg?branch=master)](https://travis-ci.org/Kr00lIX/gen_worker)
[![Hex pm](https://img.shields.io/hexpm/v/gen_worker.svg?style=flat)](https://hex.pm/packages/gen_worker)

Generic Worker behavior that helps to run task at a specific time with a specified frequency.

## Installation and usage
It's available in Hex, the package can be installed as:

1. Add `gen_worker` to your list of dependencies in mix.exs:
```elixir
def deps do
  [
    {:gen_worker, ">= 0.0.1"}
  ]
end
```
Then run `mix deps.get` to get the package.

1. Define your business logic:

```elixir
defmodule MyWorker do
  use GenWorker, run_at: [hour: 13, minute: 59], run_every: [days: 1]

  def run do
    IO.puts "MyWorker run every day at 13:59"
  end
end
```

3. Add it to the application supervision tree:
```elixir
def start(_type, _args) do
  import Supervisor.Spec, warn: false

  children = [
    worker(MyWorker, [])
    # ...
  ]

  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

Documentation can be found at [https://hexdocs.pm/gen_worker](https://hexdocs.pm/gen_worker).

## Supported options
`start_at` – keyword list with integers values. Supported keys: 
`:year`, `:month`, `:day`, `:hour`, `:minute`, `:second`, `:microsecond`.

`run_every` - keyword list with integers values. Supported keys: `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes`, `:seconds`, `:milliseconds`.


## License
This software is licensed under [the MIT license](LICENSE.md).