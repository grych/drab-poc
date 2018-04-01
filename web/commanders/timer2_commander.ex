defmodule DrabPoc.Timer2Commander do
  use Drab.Commander

  defhandler countdown(socket, sender, options) do
    for i <- 1..options["seconds"] do
      set_prop socket, this_commander(sender) <> " .output", innerText: options["seconds"] - i
      Process.sleep(1000)
    end
  end
end
