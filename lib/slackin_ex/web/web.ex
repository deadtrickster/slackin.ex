defmodule SlackinEx.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use SlackinEx.Web, :controller
      use SlackinEx.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SlackinEx.Web
      import Plug.Conn
      import SlackinEx.Web.Router.Helpers
      import SlackinEx.Web.Gettext
      alias SlackinEx.Slack
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/slackin_ex/web/templates",
                        namespace: SlackinEx.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SlackinEx.Web.Router.Helpers
      import SlackinEx.Web.ErrorHelpers
      import SlackinEx.Web.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SlackinEx.Web.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
