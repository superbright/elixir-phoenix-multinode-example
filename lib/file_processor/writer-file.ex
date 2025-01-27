defmodule FileProcessor.Writer do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Phoenix.PubSub.subscribe(FileProcessor.PubSub, "file_updates")
    {:ok, %{output_file: nil}}
  end

  def set_output_file(path) do
    GenServer.cast(__MODULE__, {:set_output, path})
  end

  def handle_cast({:set_output, path}, state) do
    {:noreply, %{state | output_file: path}}
  end

  def handle_info({:new_line, line}, %{output_file: path} = state) when not is_nil(path) do
    File.write!(path, line <> "\n", [:append])
    Logger.info("Wrote line: #{line}")
    {:noreply, state}
  end

  def handle_info({:new_line, _}, state), do: {:noreply, state}
end