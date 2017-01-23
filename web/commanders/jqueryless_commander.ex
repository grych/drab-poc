defmodule DrabPoc.JquerylessCommander do
  require Logger
  use Drab.Commander, onload: :page_loaded, modules: [] # only default Drab.Core

  def page_loaded(socket) do
    socket |> execjs("console.log('Alert from the other side!');")
  end

  def clicked(socket, payload) do
    socket |> console("You've sent me this: #{payload |> inspect}")
  end
end
