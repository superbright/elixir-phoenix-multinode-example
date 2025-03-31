defmodule FileProcessor.StateManager do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  def init(state) do
    {:ok, state}
  end

  def write(content) do
    GenServer.call({:global, __MODULE__}, {:write, content})
  end

  def read do
    GenServer.call({:global, __MODULE__}, :read)
  end

  def handle_call({:write, content}, _from, _state) do
    File.write!("output.txt", content)
    {:reply, :ok, content}
  end

  def handle_call(:read, _from, state) do
    content = case File.read("output.txt") do
      {:ok, data} -> data
      {:error, _} -> ""
    end
    {:reply, content, state}
  end
end
