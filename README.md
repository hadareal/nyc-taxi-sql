# NYC Taxi SQL

A PostgreSQL 16 sandbox loaded with NYC yellow taxi trips, used for practicing SQL.

## Setup

Requires Docker with Compose. You don't need Python on your machine, because the loader runs in a container.

```bash
cp .env.example .env              # then set a real password
docker compose up -d db           # start Postgres (data persists in the pgdata volume)
docker compose run --rm loader    # load data/*.parquet and zones (safe to re-run)
```

Put the source files in `data/` (it is gitignored):
- `yellow_tripdata_YYYY-MM.parquet` from the [NYC TLC trip record data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
- `taxi_zone_lookup.csv` from the same page

## Tables

| Table       | Contents |
|-------------|----------|
| `trips_raw` | Every trip from every parquet file. Column names are the source names in lowercase. |
| `zones`     | Taxi zone lookup (`locationid`, `borough`, `zone`, `service_zone`). |

The schema is in [db/schema.sql](db/schema.sql).

## Writing queries

Write one query per file in `sql/`, then run it:

```bash
docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/01_example.sql
```

For an interactive shell:

```bash
docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

Any GUI client (DBeaver, pgAdmin, VS Code) can connect to `localhost:5432` with the credentials in `.env`.

## Stop / reset

```bash
docker compose down        # stop, keep data
docker compose down -v     # stop and delete the data volume
```
