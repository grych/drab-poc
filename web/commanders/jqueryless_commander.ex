defmodule DrabPoc.JquerylessCommander do
  require Logger
  use Drab.Commander,
    modules: [] # only default Drab.Core

  onload :page_loaded

  def page_loaded(socket) do
    socket |> execjs("console.log('Alert from the other side!');")
  end

  def clicked(socket, payload) do
    socket |> Drab.Browser.console("You've sent me this: #{payload |> inspect}")
  end
end
