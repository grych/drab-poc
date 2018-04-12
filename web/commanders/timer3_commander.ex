defmodule DrabPoc.Timer3Commander do
  use Drab.Commander

  defhandler countdown(socket, _sender, options) do
    if options["seconds"] > 0 && options["seconds"] <= 200 do
      for i <- 1..options["seconds"] do
        poke socket, countdown: options["seconds"] - i
      end
    end
  end
end
