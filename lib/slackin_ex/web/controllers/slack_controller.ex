defmodule SlackinEx.Web.SlackController do
  use SlackinEx.Web, :controller

  def invite(conn, params) do
    ## returns
    ## :ok
    ## {:error, {:validation, error}}
    ## {:error, {:slack, error}}
    ## slack errors:
    result = Slack.invite(params)

    {class, message} = result_to_message(result)
    
    render conn, "invite.html", message: message, message_class: class
  end

  defp result_to_message(result) do
    case result do
      {:ok, _} -> {"success", "SUCCESS"}
      {:error, {:validation, error}} -> {"error", error}
      {:error, {:application, error}} -> {"error", error}
      {:error, {:network, _error}} -> {"error", "Network error"}
      {:error, {:slack, slack_error}} -> {"error", humanize_slack_error(slack_error)}
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
