defmodule FileProcessor.Writer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def write(content) do
    FileProcessor.StateManager.write(content)
  end

  @doc """
  Write content to a file and update the distributed state.
  """
  def write_to_file(file_path, content) do
    # Write to file
    File.write!(file_path, content)
    # Update distributed state
    write(content)
  end
end
