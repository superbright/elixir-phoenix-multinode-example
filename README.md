# Distributed File Processor

A distributed Elixir application demonstrating inter-node communication using Phoenix PubSub. The application consists of two nodes:

- Reader node: Reads a text file line by line every second
- Writer node: Receives lines from the reader and writes them to an output file

## Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 24 or later
- macOS (for the provided instructions)

## Installation

1. Clone the repository:

```bash
git clone [repository-url]
cd file_processor
```

2. Install dependencies:

```bash
mix local.hex --force
mix deps.get
```

## Running the Application

1. Create an input file (`input.txt`) with some sample content:

```bash
echo "Line 1
Line 2
Line 3
Line 4
Line 5" > input.txt
```

2. Start the reader node in first terminal:

```bash
iex --name reader@127.0.0.1 -S mix

# In the IEx shell:
iex(1)> FileProcessor.Reader.start_link([])
iex(2)> FileProcessor.Reader.start_reading("input.txt")
```

3. Start the writer node in second terminal:

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
