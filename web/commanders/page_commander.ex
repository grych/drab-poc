defmodule DrabPoc.PageCommander do
  require IEx
  require Logger
  # import Supervisor.Spec

  use Drab.Commander,
    # onload: :page_loaded, 
    # onconnect: :connected
    # ondisconnect: :disconnected,
    # access_session: [:drab_test],
    modules: [Drab.Query, Drab.Modal, Drab.Waiter]

  onload :page_loaded
  onconnect :connected
  ondisconnect :disconnected

  access_session :drab_test

  before_handler :run_before_uppercase, only: [:uppercase]
  before_handler :run_before_each
  after_handler  :run_after_except_uppercase, except: [:uppercase, :perform_long_process, :run_async_tasks]

  def run_before_uppercase(_socket, _dom_sender) do
    Logger.debug("BEFORE uppercase")
  end

  def run_before_each(_socket, _dom_sender) do
    Logger.debug("BEFORE EACH")
  end

  def run_after_except_uppercase(_socket, _dom_sender, handler_return) do
    Logger.debug("AFTER EXCEPT uppercase. Handler returned: #{inspect handler_return}")
  end

  # Drab Events
  def uppercase(socket, dom_sender) do
    t = socket |> select(:val, from: "#text_to_uppercase")
    socket |> update(:val, set: String.upcase(t), on: "#text_to_uppercase")
    Logger.debug("****** SOCKET:  #{inspect(socket)}")
    Logger.debug("****** DOM_SENDER: #{inspect(dom_sender)}")
    # raise "Bad things happeded"
    socket |> Drab.Browser.console("Hey, this is PageCommander from the server side!")
    # raise "uups, I did it again"
  end

  def perform_long_process(socket, dom_sender) do
    socket
      |> execute(:hide, on: this(dom_sender))
      |> insert(cancel_button(socket, self()), after: "[drab-click=perform_long_process]")
    start_background_process(socket) 
  end

  defp start_background_process(socket) do
    socket |> delete(class: "progress-bar-success", from: ".progress-bar")

    steps = :rand.uniform(100)
    step(socket, steps, 0)
  end

  defp step(socket, last_step, last_step) do
    update_bar(socket, last_step, last_step)
    socket |> insert(class: "progress-bar-success", into: ".progress-bar")

    case socket |> alert("Finished!", "Do you want to retry?", buttons: [ok: "Yes", cancel: "No!"]) do
      {:ok, _} -> start_background_process(socket)
      {:cancel, _} -> clean_up(socket)
    end 
  end

  defp step(socket, steps, i) do
    :timer.sleep(:rand.uniform(500)) # simulate real work
    update_bar(socket, steps, i)

    receive do
      :cancel_processing -> 
        clean_up(socket)
    after 0 -> 
      step(socket, steps, i + 1)
    end
  end

  defp update_bar(socket, steps, i) do
    socket 
      |> update(css: "width", set: "#{i * 100 / steps}%", on: ".progress-bar")
      |> update(:html, set: "#{Float.round(i * 100 / steps, 2)}%", on: ".progress-bar")
  end

  defp cancel_button(socket, pid) do
    """
     <button class="btn btn-danger" 
             drab-click="cancel_long_process" 
             data-pid="#{Drab.tokenize_pid(socket, pid)}">
    Cancel
    </button>
    """    
  end

  defp clean_up(socket) do
    socket |> delete("[drab-click=cancel_long_process]")
    socket |> execute(:show, on: "[drab-click=perform_long_process]")
  end

  def cancel_long_process(socket, dom_sender) do
    pid = Drab.detokenize_pid(socket, dom_sender["data"]["pid"])
    if Process.alive?(pid) do
      send(pid, :cancel_processing)
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
    dom_sender["data"]["sleep"]
  end

  def changed_input(socket, dom_sender) do
    socket |> update!(:text, set: String.upcase(dom_sender["val"]),  on: dom_sender["data"]["update"])
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

  def update_chat(socket, sender) do
    do_update_chat(socket, sender, sender["val"])
  end

  # /who or /w gives a presence list
  defp do_update_chat(socket, sender, "/w" <> _) do
    users = DrabPoc.Presence.get_users() |> Map.values() |> Enum.sort |> Enum.join(", ") 
    socket 
      |> update(:val, set: "", on: this(sender))
      |> add_chat_message("<span class='chat-system-message'>*** Connected users: #{users}.</span><br>")
  end

  defp do_update_chat(socket, sender, message) do
    nick = get_store(socket, :nickname, "Anonymous")
    html = "<strong>#{nick}:</strong> #{message}<br>"
    socket 
      |> update(:val, set: "", on: this(sender))
      |> add_chat_message!(html)
  end

  def update_nick(socket, sender) do
    new_nick = sender["val"]
    message = """
    <span class='chat-system-message'>
      *** <b>#{get_store(socket, :nickname, "Anonymous")}</b> is now known as 
      <b>#{new_nick}</b>
    </span><br>
    """
    socket 
      |> put_store(:nickname, new_nick)
      |> add_chat_message!(message)
    DrabPoc.Presence.update_user(Node.self(), Drab.pid(socket), new_nick)
    update_presence_list!(socket)
  end

  defp chat_message_js(message) do
    """
    var time = "<span class='chat-time'>[" + (new Date()).toTimeString().substring(0, 5) + "]</span> "
    $('#chat').append(time + #{message |> Drab.Core.encode_js})
    """
  end

  defp scroll_down!(socket) do
    socket |> execute!("animate({scrollTop: $('#chat').prop('scrollHeight')}, 500)", on: "#chat")
  end

  defp scroll_down(socket) do
    socket |> execute("animate({scrollTop: $('#chat').prop('scrollHeight')}, 500)", on: "#chat")
  end

  defp add_chat_message!(socket, message) do
    socket
      |> broadcastjs(chat_message_js(message))
      |> scroll_down!()
  end

  defp add_chat_message(socket, message) do
    execjs(socket, chat_message_js(message))
    scroll_down(socket)
  end

  defp update_presence_list!(socket) do
    users = DrabPoc.Presence.get_users() |> Map.values() |> Enum.sort |> Enum.join("<br>")
    socket |> update!(:html, set: users, on: "#presence-list")
  end

  def waiter_example(socket, _dom_sender) do
    buttons = Phoenix.View.render_to_string(DrabPoc.PageView, "waiter_example.html", [])
    socket 
      |> delete(from: "#waiter_answer_div")
      |> insert(buttons, append: "#waiter_example_div")

    answer = waiter(socket) do
      on "#waiter_example_div button", "click", fn(sender) ->
        sender["text"]
      end
      on_timeout 5000, fn ->
        "six times nine"
      end
    end

    socket 
      |> delete(from: "#waiter_example_div")
      |> update(:text, set: "Do you realy think it is #{answer}?", on: "#waiter_answer_div")
  end

  def raise_error(_socket, _dom_sender) do
    map = %{x: 1, y: 2}
    # the following line will cause KeyError
    map.z
  end

  def self_kill(_socket, _dom_sender) do
    Process.exit(self(), :kill)
  end

  # Drab Callbacks 
  def page_loaded(socket) do
    Logger.debug("LOADED: Counter: #{get_store(socket, :counter)}")
    socket 
    |> Drab.Browser.console("Launched onload callback")
    |> update(:val, set: get_session(socket, :drab_test), on: "#show_session_test")
    |> update(:val, set: get_store(socket, :nickname, ""), on: "#nickname" )
  end

  def connected(socket) do
    # display chat join message
    nickname = get_store(socket, :nickname, "Anonymous")
    joined = """
    <span class='chat-system-message'>*** <b>#{nickname}</b> has joined the chat.</span><br>
    """
    socket |> add_chat_message!(joined)
    info = "<span class='chat-system-message'>*** Type <b>/who</b> to get the presence list.</span><br>"
    socket |> add_chat_message(info)

    DrabPoc.Presence.add_user(Node.self(), Drab.pid(socket), nickname)
    put_store(socket, :my_drab_pid, Drab.pid(socket))

    update_presence_list!(socket)

    Logger.debug("CONNECTED: Counter: #{get_store(socket, :counter)}")
    clean_up(socket)

    # Sentix is already started within application supervisor
    Sentix.subscribe(:access_log)

    file_change_loop(socket, Application.get_env(:drab_poc, :watch_file))
  end

  def disconnected(store, session) do
    # this is a guy who just left
    # Drab is already dead, so I must take a PID from the Store (set on connect)
    # removed_user = DrabPoc.Presence.get_user(Node.self(), store[:my_drab_pid])
    DrabPoc.Presence.remove_user(Node.self(), store[:my_drab_pid])
    # one Drab to broadcast, one Drab to rule them all
    if random_guy = Enum.at(DrabPoc.Presence.get_users(), 0) do
      {{_, random_guys_pid}, _} = random_guy
      socket = GenServer.call(random_guys_pid, :get_socket)
      removed_user = store[:nickname] || "Anonymous"
      html = "<span class='chat-system-message'>*** <b>#{removed_user}</b> has left.</span><br>"
      add_chat_message!(socket, html)
      update_presence_list!(socket)
    end

    # Enum.map(remaining_users, 
    #   fn {{_n, p}, _u} -> 
    #     socket = GenServer.call(p, :get_socket)

    #     html = "*** <span class='chat-system-message'><b>#{removed_user}</b> has left.</span><br>"
    #     DrabPoc.PageCommander.add_chat_message(socket, html)
    # end)

    Logger.debug("DISCONNECTED, store: #{store |> inspect}")
    Logger.debug("            session: #{session |> inspect}")
    :ok
  end

  defp file_change_loop(socket, file_path) do
    receive do
      {_pid, {:fswatch, :file_event}, {^file_path, _opts}} ->
        socket |> update(:text, set: last_n_lines(file_path, 8), on: "#log_file")
      any_other ->
        Logger.debug(inspect(any_other))
      # after 1000 ->
      #   Logger.debug("ping")
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
