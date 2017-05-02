defmodule SlackinEx.Config do
  @moduledoc """
  Slackin.ex configuration
  """

  ## Slack stuff

  def slack_subdomain() do
    fetch_option(:slack_subdomain)
  end

  def slack_apitoken() do
    fetch_option(:slack_apitoken)
  end

  def slack_channels() do
    get_option(:slack_channels)
  end

  def slack_team_name() do
    get_option(:slack_team_name)
  end

  def slack_update_interval() do
    get_option(:slack_update_interval, 30_000)
  end

  def logo_url() do
    get_option(:logo_url)
  end

  def coc_url() do
    get_option(:coc_url)
  end

  def contact_email() do
    fetch_option(:contact_email)
  end

  def contact_name() do
    get_option(:contact_name, contact_email())
  end

  def badge_accent_color() do
    get_option(:badge_accent_color, "#4e2a8e")
  end

  def badge_title_background_color() do
    get_option(:badge_title_background_color, "#555")
  end

  def badge_text_color() do
    get_option(:badge_text_color, "#fff")
  end

  def badge_text_shadow_color() do
    get_option(:badge_text_shadow_color, "#010101")
  end

  def badge_title() do
    get_option(:badge_title, "slack")
  end

  def badge_pad() do
    get_option(:badge_pad, 8)
  end

  def badge_sep() do
    SlackinEx.Config.BadgeSep.get()
  end

  defmodule BadgeSep do
    def get() do
      SlackinEx.Config.cache(__MODULE__, SlackinEx.Config.get_option(:badge_sep, 4))
    end
  end

  def cache(_mod, value) do
    value
  end
  
  def get_option(name, default \\ nil) do
    string_name = String.upcase(Atom.to_string(name))
    System.get_env(string_name) ||
      Application.get_env(:slackin_ex, name, default)
  end

  defp fetch_option(name) do
    string_name = String.upcase(Atom.to_string(name))
    System.get_env(string_name) ||
      Application.fetch_env!(:slackin_ex, name)
  end

  def set_option(name, value) do
    Application.put_env(:slackin_ex, name, value)
  end

end
