defmodule DrabPoc.Presence do
  @name {:global, __MODULE__}

  require Logger

  def start_link do
    case Agent.start_link(fn -> %{} end, name: @name) do
      {:ok, pid} ->
        Logger.info "Started #{__MODULE__} server, PID: #{inspect pid}"
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Logger.info "#{__MODULE__} is already running, server PID: #{inspect pid}"
        # Process.monitor(pid)
        {:ok, pid}
    end
  end

  def add_user(node, pid, user) do 
    {:safe, u} = Phoenix.HTML.html_escape(user)
    Agent.update(@name, &Map.put(&1, {node, pid}, u))
  end

  def get_user(node, pid), do: Agent.get(@name, &Map.get(&1, {node, pid}))

  def update_user(node, pid, user), do: add_user(node, pid, user)

  def remove_user(node, pid), do: Agent.update(@name, &Map.delete(&1, {node, pid}))

  def get_users(), do: Agent.get(@name, fn map -> map end)
end
