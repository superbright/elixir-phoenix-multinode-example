defmodule FileProcessor.Reader do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def read do
    FileProcessor.StateManager.read()
  end

  @doc """
  Start reading contents from a file.
  This is a convenience function that just reads the current state.
  """
  def start_reading(_file_path) do
    read()
  end
end
