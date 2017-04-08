defmodule SlackinEx.Slack do
  alias SlackinEx.Config
  require Logger

  @moduledoc """

  Common Fuse for network/Slack 500

  if invite returns rate-limit:
  notify user and show global unavailable alert
  show "please retry after @retry seconds"

  if stat returns rate-limit:
  just hide stat from page
  [optionally do this only when stat is too old - like 5 mins]

  """

  def setup do
    :fuse.install(:slack_sync_api, {{:standard, 2, 15_000}, {:reset, 10_000}})

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
          {:ok, %{"team" => team_info}} ->
            %{"name" => team_name,
              "icon" => team_icon} = team_info

            unless Config.slack_team_name() do
              Config.set_option(:slack_team_name, team_name)
            end

            unless Config.logo_url() do
              case team_icon do
                %{"image_default" => _} ->
                  Logger.error("Team logo not set [slack].")
                  exit({:error, {:application, "Team logo not set"}})
                %{"image_132" => team_logo} ->
                  Config.set_option(:logo_url, team_logo)
              end
            end
            :ok
          error ->
            Logger.error("Error during preflight check [slack].")
            exit(error)
        end
    end
  end

  def api_available? do
    # TODO: publish change as event
    (:fuse.ask(:slack_sync_api, :async_dirty) == :ok) and (users_count() != false)
  end

  def invite(params) do
    with {:ok, email} <- validate_email(params),
      do: invite!(email)
  end

  def users_count() do
    case :ets.lookup(__MODULE__, :stat) do
      [{:stat, stat}] ->
        stat
      [] ->
        false
    end
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

  defp on_success_repsonse(response, callback) do
    case response do
      {:ok, 200, h, r} ->
        callback.(h, r)
      {:ok, 429, h, r} ->
        {retry, ""} = Integer.parse(:proplists.get_value(<<"Retry-After">>, h))
        Logger.error("Slack rate limit hit. Retry after #{retry}")
        case :hackney.body(r) do
          {:ok, body} -> Logger.error("Slack rate-limit message: #{body}")
          {:error, _} -> Logger.error("Unable to read body of rate-limit message")
        end
        {:retry, retry}
      {:ok, 500, _, _} ->
        :fuse.melt(:slack_sync_api)
        {:error, {:slack, :server_error}}
    end
  end

  defp process_response(response) do
    on_success_repsonse(response, fn(_h, r) ->
      process_response_body(r)
    end)
  end

  defp process_response_stream(response, callback, state) do
    on_success_repsonse(response, fn(_h, r) ->
      process_response_stream_loop(r, callback, state)
    end)
  end

  def process_response_stream_loop(r, callback, state) do
    case :hackney.stream_body(r) do
      {:ok, data} ->
        state = callback.(data, state)
        process_response_stream_loop(r, callback, state)
      :done ->
        callback.(:done, state)
      {:error, reason} ->
        {:error, {:network, reason}}
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
    "https://#{SlackinEx.Config.slack_subdomain()}.slack.com/api/users.admin.invite?token=#{SlackinEx.Config.slack_apitoken()}"
  end

  defp users_list_url do
    "https://#{SlackinEx.Config.slack_subdomain()}.slack.com/api/users.list?token=#{SlackinEx.Config.slack_apitoken()}&presence=1"
  end

  defp team_info_url do
    "https://#{SlackinEx.Config.slack_subdomain()}.slack.com/api/team.info?token=#{SlackinEx.Config.slack_apitoken()}"
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
    ## what about cache_ts?
    case users_list_request() do
      {:error, error} ->
        :fuse.melt(:slack_sync_api)
        {:error, {:network, error}}
      response ->
        decoder = :jsx.decoder(:jsx_users_list_callback, [], [:stream])
        callback = fn
          (:done, {:incomplete, decoder}) ->
            {:ok, :jsx_users_list_callback.counts(decoder.(:end_json))}
          (data, {:incomplete, decoder}) ->
            decoder.(data)
        end
        case process_response_stream(response, callback, {:incomplete, decoder}) do
          {:ok, counts} ->
            maybe_change_stat(counts)
            :ok
          {:retry, retry} ->
            :fuse.melt(:slack_sync_api)
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
      :blown ->
        SlackinEx.Web.Endpoint.broadcast("team:all", "api-unavailable", %{})
        :blown
    end
  end

  defp stat_fetcher_loop do
    case maybe_fetch_stat() do
      {:retry, retry} ->
        SlackinEx.Web.Endpoint.broadcast("team:all", "api-unavailable", %{})
        :timer.sleep(max(retry * 1000 + 1000, SlackinEx.Config.slack_update_interval()))
      :blown ->
        :timer.sleep(1000)
      _ ->
        :timer.sleep(SlackinEx.Config.slack_update_interval())
    end

    stat_fetcher_loop()
  end

  defp maybe_change_stat(stat) do
    case users_count() do
      ^stat ->
        :ok
      _ ->
        :ets.insert(__MODULE__, {:stat, stat})
        SlackinEx.Events.SlackHandler.handle_event(:users_count_changed, [])
    end
  end
end
