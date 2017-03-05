defmodule DrabPoc.PageController do
  use DrabPoc.Web, :controller
  use Drab.Controller, commander: DrabPoc.PageCommander
  require Logger

  def redirect_to_drab(conn, _params) do
    redirect conn, to: "/drab"
  end

  def index(conn, _params) do
    conn = put_session(conn, :drab_test, "test string from the Plug Session, set in the Controller")
    # Logger.debug(inspect(Map.get(conn.private, :phoenix_view)))
    render conn, "index.html"
  end
end
