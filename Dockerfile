FROM elixir:1.14-alpine

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache build-base

# Copy mix files
COPY mix.exs ./

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force



# Copy all application files
COPY . .

# Get dependencies
RUN mix deps.get
# Compile the project
RUN mix compile

# Make start script executable
RUN chmod +x start.sh



ENTRYPOINT ["/app/start.sh"]
