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

  # scope "/drab/", DrabPoc do
  #   get "create_channel", DrabController, :create_channel
  # end

  scope "/" do
    get "/", Elph.PageController, :redirect_to_drab
  end

  scope "/drab", DrabPoc do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DrabPoc do
  #   pipe_through :api
  # end
end
