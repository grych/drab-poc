defmodule DrabPoc.Router do
  use DrabPoc.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    get "/", DrabPoc.PageController, :redirect_to_drab
  end

  scope "/drab", DrabPoc do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/docs", DocsController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DrabPoc do
  #   pipe_through :api
  # end
end
