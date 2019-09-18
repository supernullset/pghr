defmodule Pghr.ThroughputWorker do
  use GenServer

  alias Pghr.Item
  alias Pghr.Repo

  def start_link(shard) do
    GenServer.start_link(__MODULE__, shard, [])
  end

  def init(shard) do
    Process.send(self(), :run, [])
    {:ok, shard}
  end

  def handle_info(:run, shard) do
      random_item_id = Enum.random(shard)
      random = Enum.random(shard)

#      IO.inspect("updating: #{random_item_id}")
      {:ok, _} =
        %Item{id: random_item_id}
        |> Ecto.Changeset.change(%{mumble3: "New Mumble #{random}"})
        |> Repo.update()

      Process.send(self(), :run, [])
      {:noreply, shard}
  end
end
