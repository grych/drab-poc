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

  def add_user(ref, user) do
    # {:safe, u} = Phoenix.HTML.html_escape(user)
    Agent.update(@name, &Map.put(&1, ref, user))
  end

  def get_user(ref), do: Agent.get(@name, &Map.get(&1, ref))

  def update_user(ref, user), do: add_user(ref, user)

  def remove_user(ref), do: Agent.update(@name, &Map.delete(&1, ref))

  def get_users(), do: Agent.get(@name, fn map -> map end)
end
