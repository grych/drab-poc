defmodule DrabPoc.JquerylessController do
  use DrabPoc.Web, :controller
  # use Drab.Controller #, commander: DrabPoc.JquerylessCommander

  def index(conn, _params) do
    render conn, "index.html"
  end
end
