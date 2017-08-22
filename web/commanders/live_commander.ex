defmodule DrabPoc.LiveCommander do
  require IEx
  require Logger
  import Phoenix.HTML

  use Drab.Commander, modules: [Drab.Live, Drab.Element, Drab.Waiter]

  onconnect :connected
  ondisconnect :disconnected
  onload :page_loaded
  access_session [:drab_test, :country_code]
  broadcasting :same_controller

  def uppercase(socket, sender) do
    text = sender.params["text_to_uppercase"]
    poke socket, text: String.upcase(text)
  end

  def lowercase(socket, sender) do
    text = sender.params["text_to_uppercase"]
    poke socket, text: String.downcase(text)
  end

  def replace_list(socket, _sender) do
    Drab.Live.poke socket, users: ["Mścisław", "Bożydar", "Mściwój", "Bogumił", "Mirmił"]
  end

  def replace_title(socket, _sender) do
    Drab.Live.poke socket, title: "New, better Title"
  end

  def add_to_list(socket, _sender) do
    users = Drab.Live.peek(socket, :users)
    Drab.Live.poke socket, users: users ++ ["Hegemon"]
  end

  def clicked_sleep_button(socket, sender) do
    button_no = sender["data"]["sleep"] |> String.to_integer()
    
    cl = peek socket, :sleep_button_classes
    poke socket, sleep_button_classes: %{cl | button_no => "btn-danger"}

    Process.sleep(button_no * 1000)
    
    cl = peek socket, :sleep_button_classes
    poke socket, sleep_button_classes: %{cl | button_no => "btn-primary"}    
  end

  def run_async_tasks(socket, _sender) do
    poke socket, async_task_label: "danger", async_task_status: "running"
    set_attr(socket, ".task[task-id]", class: "task label label-danger")

    tasks = Enum.map(1..54, fn(i) -> Task.async(fn -> 
        Process.sleep(:rand.uniform(4000)) # simulate real work
        set_prop(socket, ".task[task-id='#{i}']", className: "task label label-success")
      end)
    end)

    begin_at = :os.system_time(:millisecond)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
    end_at = :os.system_time(:millisecond)
    
    poke socket, async_task_label: "success", async_task_status: 
      "finished in #{(end_at - begin_at)/1000} seconds"
  end

  def perform_long_process(socket, _sender) do
    poke socket, progress_bar_class: "progress-bar-danger", long_process_button_text: "Processing..."

    steps = :rand.uniform(100)
    for i <- 1..steps do
      Process.sleep(:rand.uniform(500)) #simulate real work
      poke socket, bar_width: Float.round(i * 100 / steps, 2)
    end

    poke socket, progress_bar_class: "progress-bar-success", long_process_button_text: "Click me to restart"
  end

  def changed_label(socket, sender) do
    {:safe, label} =  Phoenix.HTML.html_escape(sender["value"])
    poke socket, label: label
  end

  def increase_counter(socket, _sender) do
    counter = get_store(socket, :counter) || 0
    put_store(socket, :counter, counter + 1)
  end

  def show_counter(socket, _sender) do
    poke socket, counter: get_store(socket, :counter)
  end




  def update_chat(socket, sender) do
    do_update_chat(socket, sender, sender["value"])
  end

  # /who or /w gives a presence list
  defp do_update_chat(socket, sender, "/w" <> _) do
    users = DrabPoc.Presence.get_users() |> Map.values() |> Enum.sort |> Enum.join(", ") 
    set_prop socket, this(sender), value: ""
    socket  |> add_chat_message(~E"""
      <span class='chat-system-message'>*** Connected users: <%= users %>.</span><br>
      """ |> safe_to_string())
  end

  defp do_update_chat(socket, sender, message) do
    nick = get_store(socket, :nickname, anon_nickname(socket)) #|> html_escape() |> safe_to_string()
    html = ~E"<strong><%= nick %>:</strong> <%= message %><br>" |> safe_to_string()
    set_prop socket, this(sender), value: ""
    socket |> add_chat_message!(html)
  end

  def update_nick(socket, sender) do
    new_nick = sender["value"] 
    message = ~E"""
    <span class='chat-system-message'>
      *** <b><%= get_store(socket, :nickname, anon_nickname(socket)) %></b> is now known as 
      <b><%= (new_nick) %></b>
    </span><br>
    """ |> safe_to_string()
    socket 
      |> put_store(:nickname, new_nick)
      |> add_chat_message!(message)
    DrabPoc.Presence.update_user(Node.self(), Drab.pid(socket), new_nick)
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
    document.querySelector('#chat').insertAdjacentHTML('beforeend', time + #{message |> Drab.Core.encode_js})
    """
  end

  defp scroll_down!(subject) do
    # socket |> execute!(animate: ["{scrollTop: $('#chat').prop('scrollHeight')}", 500], on: "#chat") 
    # subject |> execute!("animate({scrollTop: $('#chat').prop('scrollHeight')},500)", on: "#chat")
    broadcast_js subject, "document.querySelector('#chat').scrollTop = document.querySelector('#chat').scrollHeight"
  end

  defp scroll_down(socket) do
    # socket |> execute(animate: ["{scrollTop: $('#chat').prop('scrollHeight')}", 500], on: "#chat") 
    # socket |> execute("animate({scrollTop: $('#chat').prop('scrollHeight')},500)", on: "#chat")
    exec_js socket, "document.querySelector('#chat').scrollTop = document.querySelector('#chat').scrollHeight"
  end

  defp add_chat_message!(subject, message) do
    subject |> broadcast_js(chat_message_js(message))
    subject |> scroll_down!()
  end

  defp add_chat_message(socket, message) do
    exec_js(socket, chat_message_js(message))
    scroll_down(socket)
  end

  defp update_presence_list!(socket_or_subject) do
    users = DrabPoc.Presence.get_users() 
      |> Map.values() 
      |> Enum.sort() 
      |> Enum.map(&html_escape/1)
      |> Enum.map(&safe_to_string/1)
      |> Enum.join("<br>")
    # socket_or_subject |> update!(:html, set: users, on: "#presence-list")
    broadcast_prop socket_or_subject, "#presence-list", innerHTML: users
  end



  def waiter_example(socket, _dom_sender) do
    buttons = render_to_string("waiter_example.html", [])

    set_prop socket, "#waiter_answer_div", innerHTML: nil
    insert_html socket, "#waiter_example_div", :beforeend, buttons

    answer = waiter(socket) do
      on "#waiter_example_div button", "click", fn(sender) ->
        sender["text"]
      end
      on_timeout 5500, fn ->
        "six times nine"
      end
    end

    set_prop socket, "#waiter_example_div", innerHTML: nil
    set_prop socket, "#waiter_answer_div", innerText: "Do you realy think it is #{answer}?"
  end


  def raise_error(_socket, _dom_sender) do
    map = %{x: 1, y: 2}
    # the following line will cause KeyError
    map.z
  end

  def self_kill(_socket, _dom_sender) do
    Process.exit(self(), :kill)
  end


  def enlage_your_button_now(socket, _sender) do
    poke socket, button_height: peek(socket, :button_height) + 2
  end

  defp file_change_loop(socket, file_path) do
    receive do
      {_pid, {:fswatch, :file_event}, {^file_path, _opts}} ->
        socket |> poke(access_log: last_n_lines(file_path, 5))
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

  def changed_input(socket, sender) do
    broadcast_prop socket, sender["dataset"]["update"], innerText: String.upcase(sender["value"])
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

    DrabPoc.Presence.add_user(Node.self(), Drab.pid(socket), nickname)
    put_store(socket, :my_drab_pid, Drab.pid(socket))

    update_presence_list!(socket)


    # Sentix is already started within application supervisor
    Sentix.subscribe(:access_log)

    file_change_loop(socket, Application.get_env(:drab_poc, :watch_file))
  end


  def disconnected(store, session) do
    # Drab is already dead, so we are broadcating using same_controller()
    DrabPoc.Presence.remove_user(Node.self(), store[:my_drab_pid])

    removed_user = store[:nickname] || anon_with_country_code(session[:country_code])
    html = ~E"<span class='chat-system-message'>*** <b><%= removed_user %></b> has left.</span><br>" |> safe_to_string()
    add_chat_message!(same_controller(DrabPoc.LiveController), html)
    update_presence_list!(same_controller(DrabPoc.LiveController))

    :ok
  end


  def page_loaded(socket) do
    set_prop socket, "#show_session_test", value: get_session(socket, :drab_test)
    set_prop socket, "#nickname", value: get_store(socket, :nickname, "")
  end
end
