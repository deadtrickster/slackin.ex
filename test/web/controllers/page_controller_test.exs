defmodule SlackinEx.Web.PageControllerTest do
  use SlackinEx.Web.ConnCase

  alias SlackinEx.Config

  @valid_attrs %{
    email: Integer.to_string(:os.system_time(:milli_seconds)) <> "qwe@ndfjviydf8osnfdfnhvdnfvdfvdfvhngysd8vbdfbyfivb.com"
  }
  @invalid_attrs %{
    email: "unvalidemail"
  }

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    body = assert html_response(conn, 200)

    assert body =~ Config.slack_subdomain
    assert body =~ Config.slack_team_name
  end

  test "Show badge", %{conn: conn} do
    conn = get conn, "/badge.svg"
    body = assert response(conn, 200)

    assert body =~ "svg"
    assert body =~ "slack"
  end

  test "Error if coc is not passed", %{conn: conn} do
    conn = post conn, "/invite", @valid_attrs
    body = assert html_response(conn, 200)

    assert body =~ "Code of conduction required"
  end

  test "Invite via POST request", %{conn: conn} do
    conn = post conn, "/invite", Map.put(@valid_attrs, :coc, true)
    body = assert html_response(conn, 200)

    assert body =~ "SUCCESS"
  end
end
