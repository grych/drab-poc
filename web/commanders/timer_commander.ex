defmodule DrabPoc.TimerCommander do
  use Drab.Commander

  defhandler countdown(socket, _sender, options) do
    for i <- 1..options["seconds"] do
      set_prop socket, options["output"], innerText: options["seconds"] - i
      Process.sleep(1000)
    end
  end
end
