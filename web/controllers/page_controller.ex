defmodule DrabPoc.PageController do
  use DrabPoc.Web, :controller
  require IEx
  require Logger

  def index(conn, _params) do
    render conn, "index.html"
  end

  def uppercase(socket, sender) do
    t = List.first(Drab.Query.val(socket, "#text_to_uppercase"))
    Drab.Query.val(socket, "#text_to_uppercase", String.upcase(t))
    {socket, sender}
  end

  def perform_long_process(socket, sender) do
    for i <- 1..10 do
      :timer.sleep(:rand.uniform(750))
      Drab.Query.attr(socket, ".progress-bar", "style", "width: #{10*i}%")
      Drab.Query.html(socket, ".progress-bar", "#{10*i}%")
    end
    Drab.Query.add_class(socket, ".progress-bar", "progress-bar-success")
    {socket, sender}
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
