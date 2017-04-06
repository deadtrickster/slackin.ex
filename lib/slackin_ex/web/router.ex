defmodule SlackinEx.Web.Router do
  use SlackinEx.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    ## plug :protect_from_forgery ## nothing to protect really?
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SlackinEx.Web do
    pipe_through :browser # Use the default browser stack

    get "/", MainController, :index
    get "/badge.svg", MainController, :badge
    post "/invite", SlackController, :invite
  end

  # Other scopes may use custom stacks.
  # scope "/api", SlackinEx.Web do
  #   pipe_through :api
  # end
end
