defmodule DrabPoc.Timer3Commander do
  use Drab.Commander

  defhandler countdown(socket, _sender, options) do
    for i <- 1..options["seconds"] do
      poke socket, countdown: options["seconds"] - i
    end
  end
end
