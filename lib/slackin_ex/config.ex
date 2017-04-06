defmodule SlackinEx.Config do
  @moduledoc """
  Slackin.ex configuration
  """

  ## Slack stuff

  def slack_subdomain() do
    "slackinex"
  end

  def slack_apitocken() do
    System.get_env("SLACK_APITOKEN")
  end

  def slack_channels() do
    ""
  end

  def slack_team_name() do
    "SlackinEx"
  end

  def slack_update_interval() do
    10000
  end

  def logo_url() do
    "http://i.imgur.com/bq7UPJ6.png"
  end

  def coc_url() do
    false
  end

  def contact_email() do
    "slackinex@gmail.com"
  end

  def contact_name() do
    "slackin.ex Team"
  end

  def badge_accent_color() do
    "#4e2a8e"
  end

  def badge_title_background_color() do
    "#555"
  end

  def badge_text_color() do
    "#fff"
  end

  def badge_text_shadow_color() do
    "#010101"
  end

  def badge_title() do
    "slack"
  end

  def badge_pad() do
    8
  end

  def badge_sep() do
    4
  end
  
end
