defmodule DrabPoc.DocsController do
  use DrabPoc.Web, :controller
  use Drab.Controller #, commander: DrabPoc.QuertCommander

  def index(conn, _params) do
    conn = put_session(conn, :test, "this was set in Controller")
    render conn, "index.html"
  end
end
