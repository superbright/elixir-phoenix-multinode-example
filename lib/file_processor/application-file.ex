defmodule FileProcessor.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: FileProcessor.PubSub}
    ]

    opts = [strategy: :one_for_one, name: FileProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end