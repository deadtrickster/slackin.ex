defmodule SlackinEx.Web.TeamChannel do

  @moduledoc """
  """

  use SlackinEx.Web, :channel

  def join("team:all", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (team:lobby).
  def handle_in("slack_invite", payload, socket) do
    case SlackinEx.Slack.invite(payload) do
      {:ok, _} ->
        {:reply, :ok, socket}
      {:error, error} ->
        {:reply, {:error, %{:error => error_to_message(error)}}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp error_to_message(result) do
    case result do
      {:validation, error} -> error
      {:application, error} -> error
      {:network, _error} -> "Network error"
      {:slack, slack_error} -> humanize_slack_error(slack_error)
    end
  end

  defp humanize_slack_error(slack_error) do
    case slack_error do
      :server_error -> "Slack API server error"
      "already_invited" -> "User has already received an email invitation"
      "already_in_team" -> "User is already part of the team"
      "sent_recently" -> "When using resend=true, the email has been sent recently already"
      "user_disabled" -> "User account has been deactivated"
      "missing_scope" -> "Using an access_token not authorized for 'client' scope"
      "invalid_email" -> "Invalid email address"
      "invalid_auth" -> "Invalid configuration"
      "account_inactive" -> "Invalid configuration"
      _ -> "Unknown slack error: " <> slack_error
    end
  end

end
