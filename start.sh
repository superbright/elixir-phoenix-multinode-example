#!/bin/sh

# Enable IPv6 for Erlang
export ERL_AFLAGS="-proto_dist inet6_tcp"

echo "Starting node with name: $NODE_NAME"

# Start the node and run the application without interactive shell
exec elixir --name "$NODE_NAME" --cookie secret -S mix run --no-halt
