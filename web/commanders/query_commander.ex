defmodule DrabPoc.QueryCommander do
  require IEx
  require Logger
  # import Supervisor.Spec
  import Phoenix.HTML

  use Drab.Commander,
    modules: [Drab.Query, Drab.Modal, Drab.Waiter]

  onload :page_loaded
  onconnect :connected
  ondisconnect :disconnected

  access_session [:drab_test, :country_code]

  before_handler :run_before_uppercase, only: [:uppercase]
  before_handler :run_before_each
  after_handler  :run_after_except_uppercase, except: [:uppercase, :perform_long_process, :run_async_tasks]

  broadcasting :same_controller

  defhandler run_before_uppercase(_socket, _dom_sender) do
    Logger.debug("BEFORE uppercase")
  end

  defhandler run_before_each(_socket, _dom_sender) do
    Logger.debug("BEFORE EACH")
  end

  defhandler run_after_except_uppercase(_socket, _dom_sender, handler_return) do
    Logger.debug("AFTER EXCEPT uppercase. Handler returned: #{inspect handler_return}")
  end

  # Drab Events
  defhandler uppercase(socket, dom_sender) do
    t = socket |> select(:val, from: "#text_to_uppercase")
    socket |> update(:val, set: String.upcase(t), on: "#text_to_uppercase")
    Logger.debug("****** SOCKET:  #{inspect(socket)}")
    Logger.debug("****** DOM_SENDER: #{inspect(dom_sender)}")
    # raise "Bad things happeded"
    socket |> Drab.Browser.console("Hey, this is QueryCommander from the server side!")
    # raise "uups, I did it again"
    # spawn_link fn -> looop(socket) end
    # :timer.sleep(10000000)
  end

  # defp looop(socket) do
  #   :timer.sleep(5000)
  #   IO.puts "looop #{self() |> inspect}"
  #   looop(socket)
  # end

  defhandler perform_long_process(socket, dom_sender) do
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
             data-pid="#{Drab.tokenize(socket, pid)}">
    Cancel
    </button>
    """
  end

  defp clean_up(socket) do
    socket |> delete("[drab-click=cancel_long_process]")
    socket |> execute(:show, on: "[drab-click=perform_long_process]")
  end

  defhandler cancel_long_process(socket, dom_sender) do
    pid = Drab.detokenize(socket, dom_sender["data"]["pid"])
    if Process.alive?(pid) do
      send(pid, :cancel_processing)
    end
  end

  defhandler run_async_tasks(socket, _dom_sender) do
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

  defhandler clicked_sleep_button(socket, dom_sender) do
    socket |> update(class: "btn-primary", set: "btn-danger", on: this(dom_sender))
    :timer.sleep(dom_sender["data"]["sleep"] * 1000)
    socket |> update(class: "btn-danger", set: "btn-primary", on: this(dom_sender))
    dom_sender["data"]["sleep"]
  end

  defhandler changed_input(socket, dom_sender) do
    v = dom_sender["val"]
    socket |> update!(:text, set: String.upcase(v),  on: dom_sender["data"]["update"])
  end

  defhandler increase_counter(socket, _dom_sender) do
    counter = get_store(socket, :counter) || 0
    put_store(socket, :counter, counter + 1)
  end

  defhandler show_counter(socket, _dom_sender) do
    counter = get_store(socket, :counter)
    socket |> alert("Counter", "Counter value: #{counter}")
    socket
  end

  defhandler update_chat(socket, sender) do
    do_update_chat(socket, sender, sender["val"])
  end

  # /who or /w gives a presence list
  defp do_update_chat(socket, sender, "/w" <> _) do
    users = DrabPoc.Presence.get_users() |> Map.values() |> Enum.sort |> Enum.join(", ")
    socket
      |> update(:val, set: "", on: this(sender))
      |> add_chat_message(~E"""
        <span class='chat-system-message'>*** Connected users: <%= users %>.</span><br>
        """ |> safe_to_string())
  end

  defp do_update_chat(socket, sender, message) do
    nick = get_store(socket, :nickname, anon_nickname(socket))
    html = ~E"<strong><%= nick %>:</strong> <%= message %><br>" |> safe_to_string()
    socket
      |> update(:val, set: "", on: this(sender))
      |> add_chat_message!(html)
  end

  defhandler update_nick(socket, sender) do
    new_nick = sender["val"]
    message = ~E"""
    <span class='chat-system-message'>
      *** <b><%= get_store(socket, :nickname, anon_nickname(socket)) %></b> is now known as
      <b><%= (new_nick) %></b>
    </span><br>
    """ |> safe_to_string()
    socket
      |> put_store(:nickname, sender["val"])
      |> add_chat_message!(message)
    DrabPoc.Presence.update_user(get_store(socket, :my_drab_ref), new_nick)
    update_presence_list!(socket)
  end

  defp anon_nickname(socket) do
    country = get_session(socket, :country_code)
    anon_with_country_code(country)
  end

  defp anon_with_country_code(country) do
    if country && country != :ZZ do
      "Anonymous (#{country})"
    else
      "Anonymous"
    end
  end

  defp chat_message_js(message) do
    """
    var time = "<span class='chat-time'>[" + (new Date()).toTimeString().substring(0, 5) + "]</span> "
    $('#chat').append(time + #{message |> Drab.Core.encode_js})
    """
  end

  defp scroll_down!(socket_or_topic) do
    # socket |> execute!(animate: ["{scrollTop: $('#chat').prop('scrollHeight')}", 500], on: "#chat")
    socket_or_topic |> execute!("animate({scrollTop: $('#chat').prop('scrollHeight')},500)", on: "#chat")
  end

  defp scroll_down(socket_or_topic) do
    # socket |> execute(animate: ["{scrollTop: $('#chat').prop('scrollHeight')}", 500], on: "#chat")
    socket_or_topic |> execute("animate({scrollTop: $('#chat').prop('scrollHeight')},500)", on: "#chat")
  end

  defp add_chat_message!(socket_or_topic, message) do
    socket_or_topic |> broadcast_js(chat_message_js(message))
    socket_or_topic |> scroll_down!()
  end

  defp add_chat_message(socket, message) do
    exec_js(socket, chat_message_js(message))
    scroll_down(socket)
  end

  defp update_presence_list!(socket) do
    users = DrabPoc.Presence.get_users()
      |> Map.values()
      |> Enum.sort()
      |> Enum.map(&html_escape/1)
      |> Enum.map(&safe_to_string/1)
      |> Enum.join("<br>")
    socket |> update!(:html, set: users, on: "#presence-list")
  end

  defhandler waiter_example(socket, _dom_sender) do
    buttons = Phoenix.View.render_to_string(DrabPoc.QueryView, "waiter_example.html", [])
    # TODO: change it in a new version
    # buttons = render_to_string("waiter_example.html", [])
    socket
      |> delete(from: "#waiter_answer_div")
      |> insert(buttons, append: "#waiter_example_div")

    answer = waiter(socket) do
      on "#waiter_example_div button", "click", fn(sender) ->
        sender["text"]
      end
      on_timeout 5500, fn ->
        "six times nine"
      end
    end

    socket
      |> delete(from: "#waiter_example_div")
      |> update(:text, set: "Do you realy think it is #{answer}?", on: "#waiter_answer_div")
  end

  defhandler raise_error(_socket, _dom_sender) do
    map = %{x: 1, y: 2}
    # the following line will cause KeyError
    map.z
  end

  defhandler self_kill(_socket, _dom_sender) do
    Process.exit(self(), :kill)
  end

  # Drab Callbacks
  def page_loaded(socket) do
    Logger.debug("LOADED: Counter: #{get_store(socket, :counter)}")
    socket
      |> Drab.Browser.console("Launched onload callback")
    socket
      |> update(:val, set: get_session(socket, :drab_test, ""), on: "#show_session_test")
      |> update(:val, set: get_store(socket, :nickname, ""), on: "#nickname" )
  end

  def connected(socket) do
    # display chat join message
    nickname = get_store(socket, :nickname, anon_nickname(socket))
    joined = ~E"""
      <span class='chat-system-message'>*** <b><%= nickname %></b> has joined the chat.</span><br>
      """ |> safe_to_string()
    socket |> add_chat_message!(joined)
    info = "<span class='chat-system-message'>*** Type <b>/who</b> to get the presence list.</span><br>"
    socket |> add_chat_message(info)

    ref = make_ref()
    DrabPoc.Presence.add_user(ref, nickname)
    put_store(socket, :my_drab_ref, ref)

    update_presence_list!(socket)

    Logger.debug("CONNECTED: Counter: #{get_store(socket, :counter)}")
    clean_up(socket)

    # Sentix is already started within application supervisor
    Sentix.subscribe(:access_log)

    file_change_loop(socket, Application.get_env(:drab_poc, :watch_file))
  end

  def disconnected(store, session) do
    # Drab is already dead, so we are broadcating using same_controller()
    DrabPoc.Presence.remove_user(store[:my_drab_ref])

    removed_user = store[:nickname] || anon_with_country_code(session[:country_code])
    html = ~E"<span class='chat-system-message'>*** <b><%= removed_user %></b> has left.</span><br>" |> safe_to_string()
    add_chat_message!(same_controller(DrabPoc.QueryController), html)
    update_presence_list!(same_controller(DrabPoc.QuertController))

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
        |> String.split("\n")
        |> Enum.map(fn line -> String.slice(line, 0..60) <> " ..." end)
        |> Enum.join("\n")
        |> Regex.replace(~r/^((?:\d+\.){3})\d+( .*)$/um, a, "\\1xxx\\2")

      {stdout, retval} -> raise "last_n_lines: tail returned #{retval}. Stdout:\n#{stdout}"
    end
  end
end
