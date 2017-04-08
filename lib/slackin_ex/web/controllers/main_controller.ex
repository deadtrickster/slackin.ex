defmodule SlackinEx.Web.MainController do
  use SlackinEx.Web, :controller

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/html", nil)
    |> render("main.html", layout: false)
  end

  def badge(conn, _params) do
    conn
    |> put_resp_content_type("image/svg+xml", nil)
    |> render("badge.svg")
  end
end
