defmodule FileProcessor.Reader do
  use GenServer
  require Logger

  def start_link(_) do
    Logger.info("Starting Reader on node #{inspect(Node.self())}")
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    Logger.info("Reader initialized on node #{inspect(Node.self())}")
    {:ok, nil}
  end

  @doc """
  Read data from the distributed state manager.
  This function demonstrates inter-node communication through libcluster.
  """
  def read do
    Logger.info("Reader on node #{inspect(Node.self())} attempting to read data from distributed StateManager")
    case FileProcessor.StateManager.read() do
      {:ok, content, source_node} ->
        Logger.info("Successfully read data from node #{inspect(source_node)}")
        Logger.debug("Content: #{inspect(content)}")
        content
      error ->
        Logger.error("Error reading from StateManager: #{inspect(error)}")
        ""
    end
  end

  @doc """
  Start reading contents from a file.
  This is a convenience function that demonstrates distributed communication.
  """
  def start_reading(file_path) do
    Logger.info("Reader on node #{inspect(Node.self())} reading from #{file_path}")
    read()
  end

  @doc """
  Get information about the current cluster state.
  """
  def cluster_status do
    connected_nodes = Node.list()
    Logger.info("Current cluster status from #{inspect(Node.self())}:")
    Logger.info("Connected nodes: #{inspect(connected_nodes)}")

    %{
      current_node: Node.self(),
      connected_nodes: connected_nodes,
      cluster_size: length(connected_nodes) + 1
    }
  end
end
