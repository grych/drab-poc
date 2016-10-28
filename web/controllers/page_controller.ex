defmodule DrabPoc.PageController do
  use DrabPoc.Web, :controller
  use Drab.Controller #, commander: DrabPoc.PageCommander

  def redirect_to_drab(conn, _params) do
    redirect conn, to: "/drab"
  end

  def index(conn, _params) do
    render conn, "index.html"
  end
end
