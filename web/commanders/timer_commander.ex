defmodule DrabPoc.TimerCommander do
  use Drab.Commander

  public [:countdown]

  def countdown(socket, _sender, options) do
    IO.inspect(options)
    for i <- 1..options["seconds"] do
      Process.sleep(1000)
      set_prop socket, options["output"], innerText: options["seconds"] - i
    end
  end
end
