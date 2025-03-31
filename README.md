# Distributed File Processor

A distributed Elixir application demonstrating inter-node communication using libcluster. The application consists of two nodes:

- Reader node: Reads content from the distributed state
- Writer node: Writes content to the distributed state

## Prerequisites

- Docker
- Docker Compose

## Running the Application

1. Build and start the containers:

```bash
docker-compose up --build
```

This will start both the reader and writer nodes, which will automatically connect to each other using libcluster.

## Testing the System

1. Connect to the writer node:

```bash
docker exec -it elixir-phoenix-multinode-example_writer_1 iex --name test@writer --cookie secret --remsh writer@writer
```

2. Write some content:

```elixir
iex(1)> FileProcessor.Writer.write("Hello, distributed world!")
```

3. Connect to the reader node:

```bash
docker exec -it elixir-phoenix-multinode-example_reader_1 iex --name test@reader --cookie secret --remsh reader@reader
```

4. Read the content:

```elixir
iex(1)> FileProcessor.Reader.read()
```

## Architecture

The application uses libcluster for node discovery and communication. The nodes are configured to use the Gossip strategy for clustering. The state is managed by a distributed GenServer that ensures consistency across the cluster.

The system is containerized using Docker, with separate containers for the reader and writer nodes. They share a volume for the output file and communicate over a Docker network.

```bash
iex --name writer@127.0.0.1 -S mix

# In the IEx shell (these should run automatically as they have been moved to file: ".iex.exs"):
iex(1)> FileProcessor.Writer.start_link([])
iex(2)> Node.connect(:"reader@127.0.0.1")
iex(3)> FileProcessor.Writer.set_output_file("output.txt")
```

## Run with Docker

- to build, run

```bash
docker build -t elixir-pubsub . --output type=docker
```

run with (where 192.168.0.1 is the ip for the reader)

```bash
docker run --cap-add NET_ADMIN --cap-add SYS_MODULE --network=host --privileged -it --rm elixir-pubsub reader@192.168.0.1 -S mix
```

or with the below (default IP set to 127.0.0.1)

```bash
docker run --cap-add NET_ADMIN --cap-add SYS_MODULE --network=host --privileged -it --rm elixir-pubsub
```

## How It Works

### Architecture

The application uses:

- Phoenix.PubSub for inter-node communication
- GenServer for managing state and process behavior
- File module for file I/O operations
- Timer module for periodic processing

### Components

1. **Reader Node (FileProcessor.Reader)**

   - Reads input file line by line every second
   - Removes read line from input file
   - Broadcasts each line using Phoenix.PubSub
   - Automatically stops when file is empty

2. **Writer Node (FileProcessor.Writer)**
   - Subscribes to broadcast messages
   - Appends received lines to output file
   - Maintains output file path in state

### Communication Flow

1. Reader starts timer to process file every second
2. For each timer tick:
   - Reader reads first line from file
   - Removes line from input file
   - Broadcasts line through PubSub
3. Writer receives broadcast
4. Writer appends line to output file
5. Process continues until input file is empty

### Monitoring

Both nodes log their operations:

- Reader logs each line read
- Writer logs each line written
- Error conditions are logged

## Stopping the Application

To stop either node:

- Type `Ctrl+C` twice in the IEx shell
- Or execute `System.halt()` in the shell

## Error Handling

The application handles:

- Empty input files
- Missing input/output files
- Network disconnections
- Node failures

## Development

### Project Structure

```
file_processor/
├── lib/
│   ├── file_processor/
│   │   ├── application.ex
│   │   ├── reader.ex
│   │   └── writer.ex
│   └── file_processor.ex
├── mix.exs
└── README.md
```
