defmodule Drab do
  use GenServer
  require IEx
  require Logger
  # still hardcoded
  @controller Drab.Controller

  def onload(socket) do
    # Logger.debug inspect(controller())
    @controller.onload(socket)
  end

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    {:ok, socket}
  end


  def handle_cast({:onload, socket}, _) do
    # socket is coming from the first request from the client
    onload(socket)
    {:noreply, socket}
  end

  def handle_cast({:click, socket, %{"event_function" => evt_fun} = payload}, _) do
    # Logger.debug "***** #{inspect(socket)}"
    # Logger.debug "***** #{inspect(payload)}"
    apply(@controller, String.to_atom(evt_fun), [socket, Map.delete(payload, "event_function")]) 
    {:noreply, socket}
  end

end
