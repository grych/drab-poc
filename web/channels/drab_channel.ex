defmodule DrabPoc.DrabChannel do
  use DrabPoc.Web, :channel
  require IEx
  require Logger

  def join("drab:" <> his_id, payload, socket) do
    {:ok, pid} = Drab.start_link(socket)
    {:ok, assign(socket, :drab_pid, pid)}
  end

  def handle_in("query", %{"ok" => [query, sender_encrypted, reply]}, socket) do
    sender = Cipher.decrypt(sender_encrypted) |> :erlang.binary_to_term
    send(sender, {:got_results_from_client, reply})
    {:noreply, assign(socket, query, reply)}
  end

  def handle_in("onload", _, socket) do
    GenServer.cast(socket.assigns.drab_pid, {:onload, socket})
    {:noreply, socket}
  end

  def handle_in("click", payload, socket) do
    Logger.debug "====== #{inspect(payload)}"
    GenServer.cast(socket.assigns.drab_pid, {:click, socket, payload})
    {:noreply, socket}
  end
end
