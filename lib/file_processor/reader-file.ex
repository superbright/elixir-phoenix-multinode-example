defmodule FileProcessor.Reader do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Phoenix.PubSub.subscribe(FileProcessor.PubSub, "file_updates")
    {:ok, %{timer: nil, file_path: nil}}
  end

  def start_reading(path) do
    GenServer.cast(__MODULE__, {:start_reading, path})
  end

  def stop_reading do
    GenServer.cast(__MODULE__, :stop_reading)
  end

  def handle_cast({:start_reading, path}, state) do
    if state.timer, do: :timer.cancel(state.timer)
    {:ok, timer} = :timer.send_interval(1000, :process_line)
    {:noreply, %{state | timer: timer, file_path: path}}
  end

  def handle_cast(:stop_reading, state) do
    if state.timer, do: :timer.cancel(state.timer)
    {:noreply, %{state | timer: nil, file_path: nil}}
  end

  def handle_info(:process_line, %{file_path: path} = state) when not is_nil(path) do
    case File.read!(path) do
      "" ->
        Logger.info("File is empty, stopping reader")
        stop_reading()
      content ->
        [line | rest] = String.split(content, "\n", parts: 2)
        File.write!(path, rest)
        Phoenix.PubSub.broadcast(FileProcessor.PubSub, "file_updates", {:new_line, line})
        Logger.info("Read line: #{line}")
    end
    {:noreply, state}
  end

  def handle_info(:process_line, state), do: {:noreply, state}
  def handle_info({:new_line, _line}, state), do: {:noreply, state}
end
