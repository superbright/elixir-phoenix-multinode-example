defmodule FileProcessor.Application do
  use Application

  def start(_type, _args) do
    # IPv6 configuration is now handled by VM arguments
    Application.put_env(:kernel, :inet_dist_use_interface, {:inet6, {0,0,0,0,0,0,0,0}})

    topologies = [
      example: [
        strategy: Cluster.Strategy.Gossip,
        config: [hosts: get_hosts()]
      ]
    ]

    # Base children for all nodes
    children = [
      {Cluster.Supervisor, [topologies, [name: FileProcessor.ClusterSupervisor]]}
    ]

    # Add StateManager only on the writer node
    children = if writer_node?() do
      children ++ [{FileProcessor.StateManager, []}]
    else
      # On reader node, add the Reader process
      children ++ [{FileProcessor.Reader, []}]
    end

    opts = [strategy: :one_for_one, name: FileProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_hosts do
    hosts_string = System.get_env("CLUSTER_HOSTS", "reader@reader.local,writer@writer.local")
    String.split(hosts_string, ",") |> Enum.map(&String.to_atom/1)
  end

  defp writer_node? do
    node_name = System.get_env("NODE_NAME", "")
    String.starts_with?(node_name, "writer@")
  end
end
