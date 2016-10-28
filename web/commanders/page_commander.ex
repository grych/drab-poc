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

  # Drab Callbacks
  def page_loaded(socket) do
    # Drab.Query.attr(socket, ".progress-bar", "style", "width: 33%")
    socket
  end
end
