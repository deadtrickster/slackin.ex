defmodule SlackinEx.Events.FuseHandler do

  use SlackinEx.Events.Handler

  def handle_event({:slack_sync_api, _}, state) do
    
    SlackinEx.Cache.invalidate()
    {:ok, state}
  end
end
