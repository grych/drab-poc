defmodule DrabPoc.QueryController do
  use DrabPoc.Web, :controller
  use Drab.Controller, commander: DrabPoc.QueryCommander
  require Logger

  def redirect_to_drab(conn, _params) do
    redirect conn, to: "/drab"
  end

  def index(conn, _params) do
    conn = put_session(conn, :drab_test, "test string from the Plug Session, set in the Controller")
    # Logger.debug(inspect(conn))
    Logger.info """
    x-forwarded-for = #{get_req_header(conn, "x-forwarded-for") |> inspect}
    country_code    = #{country_code(conn)}
    """
    conn = put_session(conn, :country_code, country_code(conn))
    conn = put_session(conn, :nickname, "Anonymous #{country_code(conn)}")
    render conn, "index.html"
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
