defmodule DrabPoc.PageController do
  use DrabPoc.Web, :controller
  use Drab.Controller, onload: :page_loaded, controller: __MODULE__

  require IEx
  require Logger

  def redirect_to_drab(conn, _params) do
    redirect conn, to: "/drab"
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

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
    Drab.Query.change_class(socket, ".task", "label-success", "label-danger")
    Drab.Query.html(socket, "#async_task_status", "running")
    {_, begin_at_sec, begin_at_micsec } = :os.timestamp
    tasks = Enum.map(1..54, fn(i) -> Task.async(fn -> 
      :timer.sleep(:rand.uniform(4000))
      Drab.Query.change_class(socket, ".task[data-task_id=#{i}]", "label-danger", "label-success")
      end)
    end)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
    {_, end_at_sec, end_at_micsec } = :os.timestamp
    Drab.Query.html(socket, "#async_task_status", 
      "finished in #{((end_at_sec - begin_at_sec)*1000_000 + (end_at_micsec - begin_at_micsec))/1000_000} seconds")
    {socket, dom_sender}
  end

  # DRAB callbacks
  def page_loaded(socket) do
    Drab.Query.attr(socket, ".progress-bar", "style", "width: 0%")
    socket
  end

end
