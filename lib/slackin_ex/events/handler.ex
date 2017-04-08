defmodule SlackinEx.Events.Handler do
  defmacro __using__(_) do
    quote location: :keep do
      
      @behaviour :gen_event

      def init(_args) do
        {:ok, []}
      end
      
      def handle_event(_, state) do
        {:ok, state}
      end

      def handle_call(_, state) do
        {:ok, :ok, state}
      end

      def handle_info(_, state) do
        {:ok, state}
      end

      def code_change(_, state, _) do
        {:ok, state}
      end

      def terminate(_, _) do
        :ok
      end

      defoverridable [init: 1, handle_event: 2, handle_call: 2,
                      handle_info: 2, terminate: 2, code_change: 3]
    end
  end
end
