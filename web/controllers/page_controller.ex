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
    conn.remote_ip = #{get_req_header(conn, "x-forwarded-for") |> inspect}
    country_code = #{country_code(conn)}

    conn:
    #{conn |> inspect}
    """
    conn = put_session(conn, :country_code, country_code(conn))
    render conn, "index.html"
  end

  defp country_code(conn) do
    try do
      # {a, b, c, d} = get_req_header(conn, "x-forwarded-for")
      # ip = "#{a}.#{b}.#{c}.#{d}"
      IP2Country.whereis(get_req_header(conn, "x-forwarded-for"))
    rescue
      _ -> ""
    end    
  end
end
