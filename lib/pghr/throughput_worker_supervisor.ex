defmodule Pghr.ThroughputWorkerSupervisor do
  @moduledoc """
  The root of an application tree responsible for keeping as busy as possible
  for N seconds before self terminating.
  """
  use Supervisor

alias Pghr.Item
alias Pghr.Repo
import Ecto.Query


  @worker_id :throughput_worker

  defp chunks

  def start_link({_number_of_seconds, _number_of_rows, _number_of_workers} = args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init({number_of_seconds, number_of_rows, number_of_workers}) do
    default_children = [
      {Pghr.ThroughputWorkerTimer, number_of_seconds}
    ]
    shard_size = Integer.floor_div(number_of_rows, number_of_workers)

    IO.inspect(shard_size, label: "shard size")
    shards =
      1..number_of_rows
      |> Enum.chunk_every(shard_size)
      |> Enum.with_index

    dynamic_children = Enum.map(shards, fn {shard, i} ->
      Supervisor.child_spec({Pghr.ThroughputWorker, shard}, id: "worker-#{i}")
    end)

    Supervisor.init(default_children ++ dynamic_children, strategy: :one_for_one)
  end

  def start_run do
    IO.inspect("starting run")
    start_link({120_000, 100_000, 20})
  end

  def stop_run do
    IO.inspect("halting run")
    Supervisor.stop(__MODULE__, :brutal_kill)

    item_count = Repo.aggregate(Item, :count, :id)
    |> IO.inspect(label: "item count")


    updated = Repo.one(from(i in Item, where: like(i.mumble3, "New%"), select: count()))
    |> IO.inspect(label: "updated")

  end
end
