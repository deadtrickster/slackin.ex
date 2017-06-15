defmodule SlackinEx.Web.TeamChannelTest do
  use SlackinEx.Web.ChannelCase

  alias SlackinEx.Web.TeamChannel
  alias SlackinEx.Config

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(TeamChannel, "team:all")

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "show error if code of conduct is required and was not given", %{socket: socket} do
    Config.set_option(:coc_url, "http://google.com")
    ref = push socket, "slack_invite", %{
      "email" => "foo@bar.com"
    }
    assert_reply ref, :error, %{}
  end

  test "invite new user and give correct error message if try to invite the same user twice", %{socket: socket} do
    new_user_email = Integer.to_string(:os.system_time(:milli_seconds)) <> "qwe@ndfjviydf8osnfdfnhvdnfvdfvdfvhngysd8vbdfbyfivb.com"
    ref = push socket, "slack_invite", %{
      "email" => new_user_email,
      "coc" => "http://google.com"
    }
    assert_reply ref, :ok, %{}, 2000

    ref = push socket, "slack_invite", %{
      "email" => new_user_email,
      "coc" => "http://google.com"
    }
    assert_reply ref, :error, %{error: "User has already received an email invitation"}, 2000
  end


  # test "stat broadcasts to team:all", %{socket: socket} do
  #   assert_broadcast "stat", %{
  #     "online" => _online,
  #     "total" => _total
  #   }, 5000
  # end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
