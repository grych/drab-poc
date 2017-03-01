defmodule DrabPoc.Channel do
  use Phoenix.Channel
  require Logger

  def join("mychannel:whatever", params, socket) do
    Logger.debug("JOINED to mychannel. Params: #{inspect params}")
    {:ok, socket}
  end
end
