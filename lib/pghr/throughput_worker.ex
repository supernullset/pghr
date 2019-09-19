defmodule Pghr.ThroughputWorker do
  use GenServer

  alias Pghr.Item
  alias Pghr.Repo
  import Ecto.Query

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

    {1, _} =
      from(i in Item, where: i.id == ^random_item_id)
      |> Repo.update_all(set: [mumble3: "New Mumble #{random}"])

      Process.send(self(), :run, [])
      {:noreply, shard}
  end
end
