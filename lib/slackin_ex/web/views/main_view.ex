defmodule SlackinEx.Web.MainView do

  import SlackinEx.Config
  
  use SlackinEx.Web, :view

  def render("badge.svg", _) do
    value = if SlackinEx.Slack.api_available? do
      {active, users} = SlackinEx.Slack.users_count
      if active == 0 do
        "#{users}"
      else
        "#{active}/#{users}"
      end
    else
      "N/A"
    end

    title = badge_title()
    accent_color = badge_accent_color()
    title_background_color = badge_title_background_color()
    
    pad = badge_pad()
    sep = badge_sep()

    lw = pad + width(title) + sep ## left side width
    rw = sep + width(value) + pad ## right side width
    tw = lw + rw
    
    """
    <svg xmlns="http://www.w3.org/2000/svg" width="#{tw}" height="20">
    <rect rx="3" width="#{tw}" height="20" fill="#{title_background_color}"></rect>
    <rect rx="3" x="#{lw}" width="#{rw}" height="20" fill="#{accent_color}"></rect>
    <path d="M#{lw} 0h#{sep}v20h-#{sep}z" fill="#{accent_color}"></path>
    <g text-anchor="middle" font-family="Verdana" font-size="11">
    #{text(title, Float.round(lw / 2), 14)}
    #{text(value, lw + Float.round(rw / 2), 14)}
    </g>
    </svg>
    """
  end

  ## generate text with 1px shadow  
  defp text(str, x, y) do
    text_color = badge_text_color()
    text_shadow_color = badge_text_shadow_color()
    """
    <text fill="#{text_shadow_color}" fill-opacity=".3" x="#{x}" y="#{y+1}">#{str}</text>
    <text fill="#{text_color}" x="#{x}" y="#{y}">#{str}</text>
    """
  end

  defp width(str) do
    String.length(str) * 7
  end
end
