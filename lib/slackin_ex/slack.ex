defmodule SlackinEx.Slack do

  require Logger

  @moduledoc """
  """

  def setup do
    :fuse.install(:slack_sync_api, {{:standard, 5, 15_000}, {:reset, 30_000}})

    :ets.new(__MODULE__, [:set, :public, :named_table,
                          {:read_concurrency, true}])
  end

  def preflight_check do
    case team_info_request() do
      {:error, error} ->
        Logger.error("Error during preflight check [network].")
        exit({:error, {:network, error}})
      response ->
        case process_response(response) do
          {:ok, _} -> :ok
          error ->
            Logger.error("Error during preflight check [slack].")
            exit(error)
        end
    end

    :ok = fetch_stat()
  end

  def api_available? do
    # TODO: publish change as event
    :fuse.ask(:slack_sync_api, :async_dirty) == :ok
  end

  def invite(params) do
    with {:ok, email} <- validate_email(params),
      do: invite!(email)
  end

  def users_count() do
    [{:stat, online, total}] = :ets.lookup(__MODULE__, :stat)
    {online, total}
  end

  defp invite!(email) do
    case :fuse.ask(:slack_sync_api, :async_dirty) do
      :ok ->
        case invite_request(email) do
          {:error, error} ->
            :fuse.melt(:slack_sync_api)
            {:error, {:network, error}}
          response -> process_response(response)
        end
      :blown ->
        {:error, {:application, "Slack API is not available"}}
    end
  end

  defp invite_request(email) do
    :hackney.post(invite_url(),
      [{"content-type", "application/x-www-form-urlencoded"}],
      {:form, [email: email]})
  end

  defp team_info_request() do
    :hackney.get(team_info_url())
  end

  def process_response(response) do
    case response do
      {:ok, 200, _h, r} ->
        process_response_body(r)
      {:ok, 429, h, _} ->
        {retry, ""} = Integer.parse(:proplists.get_value(<<"Retry-After">>, h))
        Logger.error("Slack rate limit hit. Retry after #{retry}")
        {:retry, retry}
      {:ok, 500, _, _} ->
        :fuse.melt(:slack_sync_api)
        {:error, {:slack, :server_error}}
    end
  end

  defp process_response_body(r) do
    case :hackney.body(r) do
      {:ok, body} ->
        case :jsx.decode(body, [:return_maps]) do
          %{"ok" => true} = response -> {:ok, response}
          %{"error" => "invalid_auth"} ->
            :fuse.melt(:slack_sync_api)
            Logger.error("Slack error: invalid_auth")
            {:error, {:slack, "invalid_auth"}}
          %{"error" => "account_inactive"} ->
            :fuse.melt(:slack_sync_api)
            Logger.error("Slack error: account_inactive")
            {:error, {:slack, "account_inactive"}}
          %{"error" => error} -> {:error, {:slack, error}}
        end
      {:error, error} ->
        :fuse.melt(:slack_sync_api)
        {:error, {:network, error}}
    end
  end

  defp validate_email(%{"email" => email}) do
    {:ok, email}
  end
  defp validate_email(_) do
    {:error, {:validation, "Email required."}}
  end

  defp invite_url do
    "https://#{SlackinEx.Config.slack_subdomain()}.slack.com/api/users.admin.invite?token=#{SlackinEx.Config.slack_apitocken()}"
  end

  defp users_list_url do
    "https://#{SlackinEx.Config.slack_subdomain()}.slack.com/api/users.list?token=#{SlackinEx.Config.slack_apitocken()}&presence=1"
  end

  defp team_info_url do
    "https://#{SlackinEx.Config.slack_subdomain()}.slack.com/api/team.info?token=#{SlackinEx.Config.slack_apitocken()}"
  end

  def start_link do
    {:ok, spawn_link(__MODULE__, :start_stat_fetcher, [])}
  end

  def start_stat_fetcher do
    #:fuse.install(:slack_sync_api, {{:standard, 5, 15_000}, {:reset, 30_000}})
    stat_fetcher_loop()
  end

  defp users_list_request do
    :hackney.get(users_list_url())
  end

  defp fetch_stat do
    case users_list_request() do
      {:error, error} ->
        :fuse.melt(:slack_sync_api)
        {:error, {:network, error}}
      response ->
        case process_response(response) do
          {:ok, %{"members" => members}} ->
            {online, total} = count_members(members)
            ## TODO: send only when value changed
            case :ets.info(SlackinEx.PubSub) do
              :undefined -> :ok
              _ ->
                SlackinEx.Web.Endpoint.broadcast("team:all", "stat", %{"online" => online,
                                                                       "total" => total})
            end
            :ets.insert(__MODULE__, {:stat, online, total})
            :ok
          {:retry, retry} ->
            {:retry, retry}
          error ->
            :fuse.melt(:slack_sync_api)
            error
        end
    end
  end

  defp maybe_fetch_stat do
    case :fuse.ask(:slack_sync_api, :async_dirty) do
      :ok ->
        fetch_stat()
      :blown -> :ok
    end
  end

  defp stat_fetcher_loop do
    case maybe_fetch_stat() do
      {:retry, retry} ->
        :timer.sleep(retry * 1000)
      _ ->
        :timer.sleep(SlackinEx.Config.slack_update_interval())
    end

    stat_fetcher_loop()
  end

  defp count_members(members) do
    humans = Enum.filter(members, fn(member) ->
      case member do
        %{"id" => "USLACKBOT"} -> false
        %{"is_bot" => true} -> false
        %{"deleted" => true} -> false
        _ -> true
      end
    end)

    online = Enum.reduce(humans, 0, fn(member, acc) ->
      case member do
        %{"presence" => "away"} -> acc
        _ -> acc + 1
      end
    end)

    {online, Enum.count(humans)}
  end
end
