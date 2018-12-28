defmodule FlowProducersPollerTest do
  use ExUnit.Case
  doctest FlowProducers.Poller
  alias FlowProducers.Poller

  defmodule PollerProd do
    use Poller
    def poll(_) do
      count = id()
      if count < 2 do
        GenServer.call(:probe, {:poll, count})
      else
        []
      end
    end

    def id do
      Agent.get_and_update(:counter, &{&1, &1 + 1})
    end
  end

  test "poller producer" do
    {:ok, counter} = Agent.start_link(fn -> 0 end, name: :counter)
    {:ok, probe} = TestProbe.start(name: :probe)

    {:ok, poller} = GenStage.start_link(PollerProd, :ok)

    task = Task.async(fn ->
      window = Flow.Window.global |> Flow.Window.trigger_every(3)
      Flow.from_stage(poller)
      |> Flow.partition(window: window, stages: 1)
      |> Flow.reduce(fn -> 0 end, & &1 + &2)
      |> Flow.on_trigger(fn st ->
        send probe, st
        {[], st}
      end)
      |> Flow.run()
    end)

    assert {:some, message} = TestProbe.receive(probe, %TestProbe.Message{data: {:poll, 0}})
    TestProbe.reply(probe, message, [1, 2, 3])
    assert {:some, _} = TestProbe.receive(probe, %TestProbe.Message{type: :info, data: 6})
    assert {:some, message} = TestProbe.receive(probe, %TestProbe.Message{data: {:poll, 1}})
    TestProbe.reply(probe, message, [4, 5, 6])
    assert {:some, _} = TestProbe.receive(probe, %TestProbe.Message{type: :info, data: 21})
    Task.shutdown(task)
    Agent.stop(poller)
    TestProbe.stop(probe)
    Agent.stop(counter)
  end
end
