defmodule SlackinEx.Events.SlackHandler do

  use SlackinEx.Events.Handler

  def handle_event(:users_count_changed, _) do
    SlackinEx.Cache.invalidate()

    case :ets.info(SlackinEx.PubSub) do
      :undefined -> :ok
      _ ->
        case SlackinEx.Slack.users_count() do
          {online, total} ->
            SlackinEx.Web.Endpoint.broadcast("team:all", "stat", %{"online" => online,
                                                                   "total" => total})
          _ ->
            SlackinEx.Web.Endpoint.broadcast("team:all", "stat", %{"error" => "n/a"})
        end
    end
  end

end
