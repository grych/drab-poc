defmodule Drab do
  use GenServer
  require IEx
  require Logger

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    {:ok, socket}
  end

  def handle_cast({:onload, socket}, _) do
    # socket is coming from the first request from the client
    Logger.debug "ONLOAD: #{inspect(socket)}"
    # @controller.onload(socket)
    apply(controller(socket), socket.assigns.controller.__drab__().onload, [socket])
    {:noreply, socket}
  end

  def handle_cast({:click, socket, %{"event_function" => evt_fun} = payload}, _) do
    Logger.debug "***** ONCLICK #{inspect(socket)}"
    # Logger.debug "***** #{inspect(payload)}"
    apply(controller(socket), String.to_atom(evt_fun), [socket, Map.delete(payload, "event_function")]) 
    {:noreply, socket}
  end

  defp controller(socket) do
    drab_config = socket.assigns.controller.__drab__()
    drab_config.controller
  end
end
