defmodule DrabPoc.PageCommander do
  require IEx
  require Logger

  use Drab.Commander, 
    onload: :page_loaded, 
    # onconnect: :connected,
    ondisconnect: :disconnected,
    modules: [Drab.Query, Drab.Modal],
    inherit_session: [:drab_test]

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

    socket
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

  def increase_counter(socket, _dom_sender) do
    counter = get_store(socket, :counter) || 0
    put_store(socket, :counter, counter + 1)
  end

  def show_counter(socket, _dom_sender) do
    counter = get_store(socket, :counter)
    socket |> alert("Counter", "Counter value: #{counter}")
    socket
  end

  # Drab Callbacks 
  def page_loaded(socket) do
    socket 
    |> console("Launched onload callback")
    |> update(:val, set: get_store(socket, :drab_test),on: "#show_session_test")
    Logger.debug("LOADED: Counter: #{get_store(socket, :counter)}")
    connected(socket)
    put_store(socket, :counter, 100) 
  end

  def connected(socket) do
    sentix_pid = spawn_link fn ->
      file = Application.get_env(:drab_poc, :watch_file)
      ### Sentix requires fswatch installed on the system
      Sentix.start_link(:watcher, [file], monitor: :kqueue_monitor, latency: 1)
      Sentix.subscribe(:watcher)
      file_change_loop(socket, file)
    end
    Logger.debug("CONNECTED: Counter: #{get_store(socket, :counter)}")
    put_store(socket, :sentix_pid, sentix_pid)
  end

  def disconnected(socket) do
    Logger.debug("DISCONNECTED, socket: #{socket |> inspect}")
    # sentix_pid = get_store(socket, :sentix_pid)
    # Logger.debug(inspect(sentix_pid))
    socket
  end

  defp file_change_loop(socket, file_path) do
    receive do
      {_pid, {:fswatch, :file_event}, {^file_path, _opts}} ->
        socket |> update(:text, set: last_n_lines(file_path, 8), on: "#log_file")
      any_other ->
        Logger.debug(inspect(any_other))
    end
    file_change_loop(socket, file_path)
  end

  defp last_n_lines(file_path, lines) do
    case System.cmd("tail", ["-#{lines}", file_path]) do
      {stdout, 0} -> stdout
      {stdout, retval} -> raise "last_n_lines: tail returned #{retval}. Stdout:\n#{stdout}"
    end
  end
end
