defmodule FlowProducers.Queue do

  def enqueue(producer, events) when is_list(events) do
    GenServer.cast(producer, {:enqueue, events})
  end

  def enqueue(producer, event) do
    enqueue(producer, [event])
  end

  defmacro __using__(_) do
    quote do
      use GenStage

      def enqueue(events) when is_list(events) do
        FlowProducers.Queue.enqueue(__MODULE__, events)
      end

      def enqueue(event) do
        enqueue([event])
      end

      def start_link(_) do
        GenStage.start_link(__MODULE__, [], name: __MODULE__)
      end

      def init(_) do
        {:producer, {:queue.new(), 0}}
      end

      def handle_cast({:enqueue, events}, {queue, demand}) do
        queue = Enum.reduce(events, queue, &:queue.in/2)
        dispatch_events(queue, demand, [])
      end

      def handle_demand(incoming_demand, {queue, demand}) do
        dispatch_events(queue, incoming_demand + demand, [])
      end

      defp dispatch_events(queue, 0, events) do
        {:noreply, Enum.reverse(events), {queue, 0}}
      end

      defp dispatch_events(queue, demand, events) do
        case :queue.out(queue) do
          {{:value, event}, queue} ->
            dispatch_events(queue, demand - 1, [event | events])
          {:empty, queue} ->
            if poller() && demand > 0 do
              GenServer.cast(self(), :poll)
            end
            {:noreply, Enum.reverse(events), {queue, demand}}
        end
      end

      defp poller, do: false

      defoverridable [poller: 0, init: 1]
    end
  end
end
