defmodule DrabPoc.PageCommander do
  require IEx
  require Logger

  use Drab.Commander, onload: :page_loaded, modules: [Drab.Query, Drab.Modal]

  # Drab Events
  def uppercase(socket, dom_sender) do
    t = socket |> select(:val, from: "#text_to_uppercase") |> List.first()
    socket |> update(:val, set: String.upcase(t), on: "#text_to_uppercase")
    Logger.debug("****** SOCKET:  #{inspect(socket)}")
    Logger.debug("****** DOM_SENDER: #{inspect(dom_sender)}")
    socket |> console("Hey, this is PageCommander from the server side!")
  end

  def perform_long_process(socket, dom_sender) do
    socket |> delete(class: "progress-bar-success", from: ".progress-bar")

    steps = :rand.uniform(100)
    for i <- 1..steps do
      :timer.sleep(:rand.uniform(500)) # simulate real work
      socket 
        |> update(css: "width", set: "#{i * 100 / steps}%", on: ".progress-bar")
        |> update(:html, set: "#{Float.round(i * 100 / steps, 2)}%", on: ".progress-bar")
    end
    socket |> insert(class: "progress-bar-success", into: ".progress-bar")

    case socket |> alert("Finished!", "Do you want to retry?", buttons: [ok: "Yes", cancel: "No!"]) do
      {:ok, _} -> perform_long_process(socket, dom_sender)
      {:cancel, _} -> :do_nothing
    end
  end

  def run_async_tasks(socket, _dom_sender) do
    socket 
      |> update(class: "label-success", set: "label-danger", on: ".task")
      |> update(:text, set: "running", on: "#async_task_status")

    {_, begin_at_sec, begin_at_micsec } = :os.timestamp
    tasks = Enum.map(1..54, fn(i) -> Task.async(fn -> 
      :timer.sleep(:rand.uniform(4000)) # simulate real work
      socket |> update(class: "label-danger", set: "label-success", on: ".task[data-task_id=#{i}]")
      end)
    end)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
    {_, end_at_sec, end_at_micsec } = :os.timestamp
    
    socket |> update(:html, set: 
      "finished in #{((end_at_sec - begin_at_sec)*1000_000 + (end_at_micsec - begin_at_micsec))/1000_000} seconds",
      on: "#async_task_status")
  end

  def clicked_sleep_button(socket, dom_sender) do
    socket |> update(class: "btn-primary", set: "btn-danger", on: this(dom_sender))
    :timer.sleep(dom_sender["data"]["sleep"] * 1000)
    socket |> update(class: "btn-danger", set: "btn-primary", on: this(dom_sender))
  end

  def changed_input(socket, dom_sender) do
    socket |> update!(:text, set: String.upcase(dom_sender["val"]),  on: "#display_placeholder")
  end

  # Drab Callbacks
  def page_loaded(socket) do
    socket 
    |> update(:html, set: "Value set on the server side", on: "#display_placeholder")
    |> console("Launched onload callback")
  end
end
