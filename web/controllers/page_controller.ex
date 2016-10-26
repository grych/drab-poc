defmodule DrabPoc.PageController do
  use DrabPoc.Web, :controller
  require IEx
  require Logger

  def redirect_to_drab(conn, _params) do
    redirect conn, to: "/drab"
  end

  def index(conn, _params) do
    render conn, "index.html"
  end
end
