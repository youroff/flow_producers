defmodule FlowProducers.Poller do
  @callback poll(integer) :: [any]

  defmacro __using__(_) do
    quote do
      use FlowProducers.Queue
      @behaviour FlowProducers.Poller

      def handle_cast(:poll, {queue, demand}) do
        queue = poll(demand)
        |> Enum.reduce(queue, &:queue.in/2)
        dispatch_events(queue, demand, [])
      end

      defp poller, do: true
    end
  end
end
