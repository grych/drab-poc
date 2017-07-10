defmodule DrabPoc.LiveController do
  use DrabPoc.Web, :controller
  use Drab.Controller

  def index(conn, _params) do
    task_classes = for i <- 1..54, into: %{}, do: {i, "danger"}
    render conn, "index.html", text: "uppercase me",
      users: ["Dżesika", "Brajanek", "Zdzichu"], title: "Users List",
      sleep_button_classes: %{1 => "btn-primary", 2 => "btn-primary", 3 => "btn-primary"},
      label: "default", button_height: 30,
      async_task_classes: task_classes, async_task_status: "ready", async_task_label: "primary",
      bar_width: 0, progress_bar_class: "",
      long_process_button_text: "Click me to start processing ..."
  end
end
