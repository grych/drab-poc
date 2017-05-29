defmodule DrabPoc.LiveCommander do
  require IEx
  require Logger

  use Drab.Commander, modules: [Drab.Live]

  def replace_list(socket, _payload) do
    Drab.Live.poke socket, users: ["Mścisław", "Bożydar", "Mściwój", "Bogumił", "Mirmił"]
  end

  def replace_title(socket, _payload) do
    Drab.Live.poke socket, title: "New, better Title"
  end

  def add_to_list(socket, _payload) do
    users = Drab.Live.peek(socket, :users)
    Drab.Live.poke socket, users: users ++ ["Mścisław", "Bożydar", "Mściwój", "Bogumił", "Mirmił"]
  end

end
