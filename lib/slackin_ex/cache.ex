defmodule SlackinEx.Cache do

  require Logger

  def invalidate do
    Logger.debug("Invalidating cache.")
    invalidate_badge()
    invalidate_index()
    Logger.debug("Invalidating cache completed.")
  end

  defp invalidate_badge do
    module = :smerl.new(SlackinEx.Cache.Badge)

    badge = SlackinEx.Web.MainView.badge()

    body = :lists.flatten(:io_lib.format('get() -> ~p.', [badge]))

    {:ok, module} = :smerl.replace_func(module, body)

    :smerl.compile(module)
  end

  defp invalidate_index do
    module = :smerl.new(SlackinEx.Cache.Index)

    index = SlackinEx.Web.MainView.index()
      
    body = :lists.flatten(:io_lib.format('get() -> ~p.', [index]))

    {:ok, module} = :smerl.replace_func(module, body)

    :smerl.compile(module)
  end

  defmodule Badge do
    def get do
      SlackinEx.Cache.invalidate()
      ## magic!
      SlackinEx.Cache.Badge.get()
    end
  end

  defmodule Index do
    def get do      
      SlackinEx.Cache.invalidate()
      ## magic!
      SlackinEx.Cache.Index.get()
    end
  end

end
