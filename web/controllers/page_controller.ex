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
    Logger.info """
    **********************************
    conn.remote_ip = #{conn.remote_ip |> inspect}
    country_code = #{country_code(conn)}
    """
    conn = put_session(conn, :country_code, country_code(conn))
    render conn, "index.html"
  end

  defp country_code(conn) do
    try do
      {a, b, c, d} = conn.remote_ip
      ip = "#{a}.#{b}.#{c}.#{d}"
      IP2Country.whereis(ip)
    rescue
      _ -> ""
    end    
  end
end
