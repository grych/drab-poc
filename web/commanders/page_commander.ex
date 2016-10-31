defmodule DrabPoc.PageCommander do
  require IEx
  require Logger

  use Drab.Commander, onload: :page_loaded

  # Drab Events
  def uppercase(socket, dom_sender) do
    t = List.first(Drab.Query.val(socket, "#text_to_uppercase"))
    Drab.Query.val(socket, "#text_to_uppercase", String.upcase(t))

    {socket, dom_sender}
  end

  def perform_long_process(socket, dom_sender) do
    for i <- 1..10 do
      :timer.sleep(:rand.uniform(750))
      socket 
        |> attr(".progress-bar", "style", "width: #{10*i}%")
        |> html(".progress-bar", "#{10*i}%")
    end
    add_class(socket, ".progress-bar", "progress-bar-success")

    {socket, dom_sender}
  end

  def run_async_tasks(socket, dom_sender) do
    socket 
      |> change_class(".task", "label-success", "label-danger")
      |> html("#async_task_status", "running")

    {_, begin_at_sec, begin_at_micsec } = :os.timestamp
    tasks = Enum.map(1..54, fn(i) -> Task.async(fn -> 
      :timer.sleep(:rand.uniform(4000))
      change_class(socket, ".task[data-task_id=#{i}]", "label-danger", "label-success")
      end)
    end)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
    {_, end_at_sec, end_at_micsec } = :os.timestamp
    
    html(socket, "#async_task_status", 
      "finished in #{((end_at_sec - begin_at_sec)*1000_000 + (end_at_micsec - begin_at_micsec))/1000_000} seconds")

    {socket, dom_sender}
  end

  def clicked_sleep_button(socket, dom_sender) do
    prop(socket, this(dom_sender), "disabled", true)
    :timer.sleep(dom_sender["data"]["sleep"] * 1000)
    prop(socket, this(dom_sender), "disabled", false)
  end

  def changed_input(socket, dom_sender) do
    html(socket, "#display_placeholder", String.upcase(dom_sender["val"]))
  end

  # Drab Callbacks
  def page_loaded(socket) do
    html(socket, "#display_placeholder", "Value set on the server side")
    socket
  end
end
