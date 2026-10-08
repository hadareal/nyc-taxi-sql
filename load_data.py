"""Load NYC taxi parquet files and the zone lookup into Postgres using COPY.

Re-runnable: both tables are truncated and reloaded in a single transaction.
Connection settings come from PGHOST/PGPORT and POSTGRES_USER/PASSWORD/DB.
"""

import io
import os
import sys
import time
from pathlib import Path

import psycopg
import pyarrow.csv as pacsv
import pyarrow.parquet as pq

ROOT = Path(__file__).resolve().parent
DATA_DIR = ROOT / "data"
SCHEMA_FILE = ROOT / "db" / "schema.sql"
ZONES_FILE = DATA_DIR / "taxi_zone_lookup.csv"


def connect():
    return psycopg.connect(
        host=os.environ.get("PGHOST", "localhost"),
        port=os.environ.get("PGPORT", "5432"),
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        dbname=os.environ["POSTGRES_DB"],
    )


def copy_parquet(cur, path):
    """Stream one parquet file into trips_raw, one record batch at a time as CSV."""
    pf = pq.ParquetFile(path)
    columns = [name.lower() for name in pf.schema_arrow.names]
    sql = f"COPY trips_raw ({', '.join(columns)}) FROM STDIN (FORMAT csv)"
    write_opts = pacsv.WriteOptions(include_header=False)

    with cur.copy(sql) as copy:
        for batch in pf.iter_batches(batch_size=200_000):
            buf = io.BytesIO()
            pacsv.write_csv(batch, buf, write_opts)
            copy.write(buf.getvalue())


def copy_zones(cur):
    sql = "COPY zones (locationid, borough, zone, service_zone) FROM STDIN (FORMAT csv, HEADER true)"
    with cur.copy(sql) as copy, open(ZONES_FILE, "rb") as f:
        while chunk := f.read(1 << 20):
            copy.write(chunk)


def main():
    parquet_files = sorted(DATA_DIR.glob("*.parquet"))
    if not parquet_files:
        sys.exit(f"No parquet files found in {DATA_DIR}")

    with connect() as conn, conn.cursor() as cur:
        cur.execute(SCHEMA_FILE.read_text())
        cur.execute("TRUNCATE trips_raw, zones")

        for path in parquet_files:
            start = time.monotonic()
            print(f"Loading {path.name} ...", end=" ", flush=True)
            copy_parquet(cur, path)
            print(f"done in {time.monotonic() - start:.1f}s")

        print(f"Loading {ZONES_FILE.name} ...")
        copy_zones(cur)

        conn.commit()

        cur.execute("ANALYZE trips_raw")
        cur.execute("ANALYZE zones")

        print()
        for table in ("trips_raw", "zones"):
            cur.execute(f"SELECT count(*) FROM {table}")
            print(f"{table:<10} {cur.fetchone()[0]:>12,} rows")


if __name__ == "__main__":
    main()
