defmodule DrabPoc.LiveController do
  use DrabPoc.Web, :controller
  # use Drab.Controller
  use Drab.Controller, commanders: [DrabPoc.TimerCommander, DrabPoc.Timer2Commander, Elixir.DrabPoc.Timer3Commander]

  def index(conn, _params) do
    conn = put_session(conn, :drab_test, "test string from the Plug Session, set in the Controller")
    conn = put_session(conn, :country_code, country_code(conn))
    render conn, "index.html", text: "uppercase me",
      users: ["Dżesika", "Brajanek", "Zdzichu"], title: "Users List",
      sleep_button_classes: %{1 => "btn-primary", 2 => "btn-primary", 3 => "btn-primary"},
      label: "default", button_height: 30,
      async_task_status: "ready", async_task_label: "primary",
      bar_width: 0, progress_bar_class: "",
      long_process_button_text: "Click me to start processing ...",
      access_log: "... this pane will update when access.log change ...",
      counter: "",
      countdown: "here be countdown"
  end

  defp country_code(conn) do
    try do
      [ip] = get_req_header(conn, "x-forwarded-for")
      IP2Country.whereis(ip)
    rescue
      _ -> nil
    end
  end
end
