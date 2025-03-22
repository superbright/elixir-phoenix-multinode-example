FROM elixir
RUN apt update -y
COPY . /opt/pubsub
WORKDIR /opt/pubsub
RUN mix local.hex --force && mix deps.get
ENTRYPOINT [ "iex", "--name" ]
CMD ["reader@127.0.0.1", "-S", "mix" ]
