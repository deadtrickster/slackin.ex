defmodule SlackinEx.PhoenixDigestTask do
  use Mix.Releases.Plugin

  def before_assembly(%Release{} = _release, _opts) do
    Mix.Task.run("phx.digest")
    nil
  end

  def after_assembly(%Release{} = _release, _opts) do
    nil
  end

  def before_package(%Release{} = _release, _opts) do
    nil
  end

  def after_package(%Release{} = _release, _opts) do
    nil
  end

  def after_cleanup(%Release{} = _release, _opts) do
    nil
  end
end
