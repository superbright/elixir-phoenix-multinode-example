defmodule FileProcessor.Reader do
  use GenServer
  require Logger

  @default_input_file "input.txt"
  @check_interval 1000 # Check every 1 second for faster testing

  def start_link(_) do
    Logger.info("Starting Reader on node #{inspect(Node.self())}")
    # Set the Logger level to debug to see more messages
    Logger.configure(level: :debug)
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.info("Reader initialized on node #{inspect(Node.self())}")
    # Start the file monitoring process
    Process.send_after(self(), :check_file, 2000) # First check after 2 seconds
    Logger.debug("File monitoring scheduled")
    {:ok, %{last_content: ""}}
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

  @doc """
  Automatically monitor input.txt and send changes to the writer
  """
  def handle_info(:check_file, state) do
    Logger.debug("Checking file #{@default_input_file}")

    new_state = case File.read(@default_input_file) do
      {:ok, content} ->
        Logger.debug("File read successful, content length: #{String.length(content)}")
        if content != state.last_content do
          Logger.info("Detected new content in #{@default_input_file}, sending to writer")
          send_to_writer(content)
          %{state | last_content: content}
        else
          Logger.debug("No changes detected in the file")
          state
        end
      {:error, reason} ->
        Logger.warning("Could not read #{@default_input_file}: #{inspect(reason)}")
        state
    end

    # Schedule next check
    schedule_file_check()
    {:noreply, new_state}
  end

  # Private functions

  defp schedule_file_check do
    Logger.debug("Scheduling next file check in #{@check_interval}ms")
    Process.send_after(self(), :check_file, @check_interval)
  end

  defp send_to_writer(content) do
    writer_node = find_writer_node()

    Logger.debug("Looking for writer node, found: #{inspect(writer_node)}")

    if writer_node do
      Logger.info("Sending content to writer node #{inspect(writer_node)}")
      case FileProcessor.StateManager.write(content) do
        {:ok, message, node} ->
          Logger.info("Writer response: #{message} from node #{inspect(node)}")
        error ->
          Logger.error("Error sending to writer: #{inspect(error)}")
      end
    else
      # If no writer node is found in the cluster, try using the StateManager directly
      Logger.info("No writer node found, trying direct StateManager call")
      case FileProcessor.StateManager.write(content) do
        {:ok, message, node} ->
          Logger.info("Writer response via direct call: #{message} from node #{inspect(node)}")
        error ->
          Logger.error("Error sending to writer (direct call): #{inspect(error)}")
      end
    end
  end

  defp find_writer_node do
    # Find a node that starts with "writer@"
    Enum.find(Node.list(), fn node ->
      node_name = Atom.to_string(node)
      String.starts_with?(node_name, "writer@")
    end)
  end
end
