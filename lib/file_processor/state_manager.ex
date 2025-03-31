defmodule FileProcessor.StateManager do
  use GenServer
  require Logger

  def start_link(_) do
    Logger.info("Starting StateManager on node #{inspect(Node.self())}")
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  def init(state) do
    Logger.info("StateManager initialized with state: #{inspect(state)}")
    {:ok, state}
  end

  def write(content) do
    caller = Node.self()
    Logger.info("Node #{inspect(caller)} requesting write operation: #{inspect(content)}")
    GenServer.call({:global, __MODULE__}, {:write, content, caller})
  end

  def read do
    caller = Node.self()
    Logger.info("Node #{inspect(caller)} requesting read operation")
    GenServer.call({:global, __MODULE__}, {:read, caller})
  end

  def handle_call({:write, content, caller}, _from, _state) do
    Logger.info("StateManager on node #{inspect(Node.self())} handling write request from #{inspect(caller)}")
    case File.write("output.txt", content) do
      :ok ->
        Logger.info("StateManager successfully wrote content to output.txt")
        {:reply, {:ok, "Data written successfully", Node.self()}, content}
      {:error, reason} ->
        Logger.error("StateManager failed to write to output.txt: #{inspect(reason)}")
        {:reply, {:error, "Failed to write data", Node.self()}, content}
    end
  end

  def handle_call({:read, caller}, _from, state) do
    Logger.info("StateManager on node #{inspect(Node.self())} handling read request from #{inspect(caller)}")
    content = case File.read("output.txt") do
      {:ok, data} ->
        Logger.info("StateManager successfully read content from output.txt")
        data
      {:error, reason} ->
        Logger.error("Error reading file: #{inspect(reason)}")
        ""
    end
    {:reply, {:ok, content, Node.self()}, state}
  end
end
