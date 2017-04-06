defmodule SlackinEx.Web.MainController do
  use SlackinEx.Web, :controller

  def index(conn, _params) do
    conn = if SlackinEx.Slack.api_available? do
      clear_flash(conn)
    else
      put_flash(conn, :error, "Slack API is not available at the moment.")
    end
    
    {active, total} = SlackinEx.Slack.users_count
    render conn, "index.html", active: active, total: total 
  end

  def badge(conn, _params) do
    conn
    |> put_resp_content_type("image/svg+xml", nil)
    |> render("badge.svg")
  end
end
