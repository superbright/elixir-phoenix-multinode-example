defmodule FileProcessor.Writer do
  use GenServer
  require Logger

  def start_link(_) do
    Logger.info("Starting Writer on node #{inspect(Node.self())}")
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    Logger.info("Writer initialized on node #{inspect(Node.self())}")
    {:ok, nil}
  end

  @doc """
  Write data to the distributed state manager.
  This function demonstrates inter-node communication through libcluster.
  """
  def write(content) do
    Logger.info("Writer on node #{inspect(Node.self())} writing data: #{inspect(content)}")
    case FileProcessor.StateManager.write(content) do
      {:ok, message, source_node} ->
        Logger.info("Successfully wrote data to node #{inspect(source_node)}: #{message}")
        :ok
      error ->
        Logger.error("Error writing to StateManager: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Write content to a file and update the distributed state.
  This function demonstrates both local file operations and distributed communication.
  """
  def write_to_file(file_path, content) do
    Logger.info("Writer on node #{inspect(Node.self())} writing to file #{file_path}")

    # Write to local file
    result = case File.write(file_path, content) do
      :ok ->
        Logger.info("Successfully wrote to local file #{file_path}")
        :ok
      error ->
        Logger.error("Error writing to local file: #{inspect(error)}")
        {:error, "Failed to write to local file"}
    end

    # Update distributed state if local write was successful
    case result do
      :ok -> write(content)
      error -> error
    end
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
