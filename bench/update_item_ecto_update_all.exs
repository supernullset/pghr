alias Pghr.Item
alias Pghr.Repo
import Ecto.Query

IO.puts("Deleting all existing items ...")

Repo.delete_all(Item)

total_items = 100_000
runtime = 120
warmup = 30
parallel = 5

IO.puts("Creating #{total_items} new items ...")

seed_database_sql = """
DO $$
BEGIN
    FOR id IN 1..#{total_items} LOOP
        INSERT INTO items (mumble1, mumble2, mumble3)
        VALUES ('mumble', 'Mumble-' || id, 'Moar Mumble ' || id);
    END LOOP;
END; $$
"""
Ecto.Adapters.SQL.query!(Repo, "ALTER SEQUENCE items_id_seq RESTART WITH 1;", []);
Ecto.Adapters.SQL.query!(Repo, seed_database_sql, []);

item_ids = 1..total_items

item_count = Repo.aggregate(Item, :count, :id)
|> IO.inspect(label: "item count")

IO.puts("Starting test ...")
ParallelBench.run(
  fn ->
    random_item_id = Enum.random(item_ids)
    random = :rand.uniform(100_000_000_000_000)

    {1, _} =
      from(i in Item, where: i.id == ^random_item_id)
      |> Repo.update_all(set: [mumble3: "New Mumble #{random}"])
  end,
  parallel: 10,
  duration: 10
)

item_count = Repo.aggregate(Item, :count, :id)
|> IO.inspect(label: "item count")


updated = Repo.one(from(i in Item, where: like(i.mumble3, "New%"), select: count()))
|> IO.inspect(label: "updated")


"updates per s: #{updated/runtime}"
|> IO.inspect()
