defmodule DrabPoc.JquerylessCommander do
  require Logger
  use Drab.Commander, onload: :page_loaded, modules: [] # only default :core

  def page_loaded(socket) do
    socket |> execjs("console.log('Alert from the other side!');")
  end

  def clicked(socket, payload) do
    Logger.debug inspect(payload)
    socket |> console("You've sent me this: #{payload |> inspect}")
  end

end
