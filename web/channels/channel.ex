defmodule DrabPoc.Channel do
  use Phoenix.Channel
  require Logger

  def join("mychannel:whatever", _, socket) do
    Logger.debug("JOINED to mychannel")
    {:ok, socket}
  end
end
