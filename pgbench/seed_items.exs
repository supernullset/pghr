# I used this because there was a problem with `psql` on my machine.
# Rather than reinstall Postgres and invalidate existing results,
# I chose to seed the database using this Elixir process instead.
# This is the seed half of the corresponding Elixir test.

alias Pghr.Item
alias Pghr.Repo

total_items = 100_000
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
Ecto.Adapters.SQL.query!(Repo, seed_database_sql, []);
