defmodule Drab.Controller do
  require Logger
  require IEx
  
  # Drab events
  def uppercase(socket, dom_sender) do
    # socket to websocket
    Logger.debug("**** SOCKET in uppercase: #{inspect(socket)}")
    Logger.debug("----- dom_sender: #{inspect(dom_sender)}")
    t = List.first(Drab.Query.val(socket, "#text_to_uppercase"))
    Drab.Query.val(socket, "#text_to_uppercase", String.upcase(t))
    {socket, dom_sender}
  end

  def perform_long_process(socket, dom_sender) do
    for i <- 1..10 do
      :timer.sleep(:rand.uniform(750))
      Drab.Query.attr(socket, ".progress-bar", "style", "width: #{10*i}%")
      Drab.Query.html(socket, ".progress-bar", "#{10*i}%")
    end
    Drab.Query.add_class(socket, ".progress-bar", "progress-bar-success")
    {socket, dom_sender}
  end

  def run_async_tasks(socket, dom_sender) do
    Drab.Query.exchange_class(socket, ".task", "label-success", "label-danger")
    Drab.Query.html(socket, "#async_task_status", "running")
    tasks = Enum.map(1..54, fn(i) -> Task.async(fn -> 
      :timer.sleep(:rand.uniform(4000))
      Drab.Query.exchange_class(socket, ".task[data-task_id=#{i}]", "label-danger", "label-success")
      end)
    end)
    Enum.map(tasks, fn(task) -> Task.await(task) end)
    Drab.Query.html(socket, "#async_task_status", "finished")
    {socket, dom_sender}
  end

  # DRAB callbacks
  def onload(socket) do
    Drab.Query.attr(socket, ".progress-bar", "style", "width: 0%")
    # Logger.debug "HTML: #{Drab.Query.html(socket, "#first_window_output")}"
    # x = Drab.Query.val(socket, "input")
    # Logger.debug "VAL: #{inspect(x)}"
    # Drab.Query.val(socket, "input", "dupa blada")
    # Drab.Query.html(socket, "#first_window_output", "another <b>htmls</b>")
    socket
  end
end
