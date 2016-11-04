defmodule DrabPoc.PageCommander do
  require IEx
  require Logger

  use Drab.Commander, onload: :page_loaded

  # Drab Events
  def uppercase(socket, dom_sender) do
    t = List.first(Drab.Query.select(socket, "#text_to_uppercase", :val))
    Drab.Query.update(socket, "#text_to_uppercase", :val, String.upcase(t))

    # Drab.Query.update(socket, this(dom_sender), :addClass, "btn-danger")
    # delete(socket, this(dom_sender), :class, "btn-primary")
    update(socket, this(dom_sender), :class, "btn-primary", "btn-danger")

    {socket, dom_sender}
  end

  def perform_long_process(socket, dom_sender) do
    steps = :rand.uniform(100)
    for i <- 1..steps do
      :timer.sleep(:rand.uniform(500)) # simulate real work
      socket 
        |> update(".progress-bar", :attr, "style", "width: #{i * 100 / steps}%")
        |> update(".progress-bar", :html, "#{Float.round(i * 100 / steps, 2)}%")
    end
    insert(socket, ".progress-bar", :class, "progress-bar-success")

    {socket, dom_sender}
  end

  def run_async_tasks(socket, dom_sender) do
    socket 
      |> update(".task", :class, "label-success", "label-danger")
      |> update("#async_task_status", :text, "running")

    {_, begin_at_sec, begin_at_micsec } = :os.timestamp
    tasks = Enum.map(1..54, fn(i) -> Task.async(fn -> 
      :timer.sleep(:rand.uniform(4000)) # simulate real work
      update(socket, ".task[data-task_id=#{i}]", :class, "label-danger", "label-success")
      end)
    end)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
    {_, end_at_sec, end_at_micsec } = :os.timestamp
    
    update(socket, "#async_task_status", :html, 
      "finished in #{((end_at_sec - begin_at_sec)*1000_000 + (end_at_micsec - begin_at_micsec))/1000_000} seconds")

    {socket, dom_sender}
  end

  def clicked_sleep_button(socket, dom_sender) do
    update(socket, this(dom_sender), :prop, "disabled", true)
    :timer.sleep(dom_sender["data"]["sleep"] * 1000)
    update(socket, this(dom_sender), :prop, "disabled", false)
  end

  def changed_input(socket, dom_sender) do
    update(socket, "#display_placeholder", :text, String.upcase(dom_sender["val"]))
  end

  # Drab Callbacks
  def page_loaded(socket) do
    update(socket, "#display_placeholder", :html, "Value set on the server side")
    socket
  end
end
