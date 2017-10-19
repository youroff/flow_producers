defmodule FlowProducersQueueTest do
  use ExUnit.Case
  doctest FlowProducers.Queue
  alias FlowProducers.Queue

  defmodule QueueProd do
    use FlowProducers.Queue
  end

  test "consuming queue producer" do
    process = self()
    {:ok, queue} = GenStage.start_link(QueueProd, :ok)
    task = Task.async(fn ->
      window = Flow.Window.global |> Flow.Window.trigger_every(3)
      Flow.from_stage(queue)
      |> Flow.partition(window: window, stages: 1)
      |> Flow.reduce(fn -> 0 end, & &1 + &2)
      |> Flow.emit(:state)
      |> Flow.each(&send process, &1)
      |> Flow.run()
    end)

    Queue.enqueue(queue, [1,2,3])
    assert_receive 6

    Queue.enqueue(queue, 4)
    Queue.enqueue(queue, 5)
    Queue.enqueue(queue, 6)
    assert_receive 21

    Task.shutdown(task)
    GenStage.stop(queue)
  end
end
