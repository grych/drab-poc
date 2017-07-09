defmodule DrabPoc.LiveController do
  use DrabPoc.Web, :controller
  use Drab.Controller

  def index(conn, _params) do
    render conn, "index.html", text: "uppercase me",
      users: ["Dżesika", "Brajanek", "Zdzichu"], title: "Users List",
      sleep_button_classes: %{1 => "btn-primary", 2 => "btn-primary", 3 => "btn-primary"},
      label: "default", button_height: 30
  end
end
