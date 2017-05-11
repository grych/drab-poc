defmodule DrabPoc.PageController do
  use DrabPoc.Web, :controller
  use Drab.Controller, commander: DrabPoc.PageCommander
  require Logger

  def redirect_to_drab(conn, _params) do
    redirect conn, to: "/drab"
  end

  def index(conn, _params) do
    conn = put_session(conn, :drab_test, "test string from the Plug Session, set in the Controller")
    # Logger.debug(inspect(conn))
    conn = put_session(conn, :country_code, remote_ip(conn))
    render conn, "index.html"
  end

  defp remote_ip(conn) do
    try do
      IP2Country.whereis(conn.remote_ip)
    rescue
      _ -> ""
    end    
  end
end
