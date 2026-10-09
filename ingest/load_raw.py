"""
Load: land the extracted files in the warehouse (schemas raw_tlc and raw_weather).

Trip files are loaded exactly as published, every month into one table per service,
matched by column name so schema drift (TLC added request_source in 2026) lands as
nulls instead of breaking the load. Each row keeps _source_file and _loaded_at.
Weather lands as its JSON payload; the extract manifest is loaded too.

    python ingest/load_raw.py
On Snowflake: ingest/snowflake_load.sql.
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
DB = ROOT / "warehouse" / "curbside.duckdb"


def main() -> None:
    manifest_path = RAW / "_manifest.json"
    if not manifest_path.exists():
        raise SystemExit("Nothing extracted yet. Run ingest/extract.py first.")
    manifest = json.loads(manifest_path.read_text())
    DB.parent.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DB))
    con.execute("set preserve_insertion_order = false")
    loaded_at = datetime.now(timezone.utc).isoformat(timespec="seconds")
    for schema in ("raw_tlc", "raw_weather"):
        con.execute(f"create schema if not exists {schema}")
    print(f"Loading into {DB.relative_to(ROOT)}")

    for service in ("yellow", "green"):
        files = [m for m in manifest if m["kind"] == service]
        paths = [(RAW / m["file"]).as_posix() for m in files]
        con.execute(f"""
            create or replace table raw_tlc.{service}_trips as
            select * exclude (filename),
                   regexp_extract(filename, '[^/]+$') as _source_file,
                   cast('{loaded_at}' as timestamp)   as _loaded_at
            from read_parquet({paths}, union_by_name = true, filename = true)
        """)
        n = con.execute(f"select count(*) from raw_tlc.{service}_trips").fetchone()[0]
        expected = sum(m["rows"] for m in files)
        if n != expected:
            raise SystemExit(f"{service}: loaded {n:,} rows, manifest says {expected:,}")
        print(f"  raw_tlc.{service}_trips {n:>14,} rows from {len(files)} files")

    con.execute(f"""create or replace table raw_tlc.taxi_zones as
        select *, 'taxi_zone_lookup.csv' as _source_file, cast('{loaded_at}' as timestamp) as _loaded_at
        from read_csv('{(RAW / 'tlc' / 'taxi_zone_lookup.csv').as_posix()}', header = true, all_varchar = true)""")
    con.execute(f"""create or replace table raw_weather.central_park_daily as
        select json as payload, 'central_park_daily.json' as _source_file, cast('{loaded_at}' as timestamp) as _loaded_at
        from read_json_objects('{(RAW / 'weather' / 'central_park_daily.json').as_posix()}')""")
    con.execute(f"create or replace table raw_tlc._extract_manifest as select * from read_json_auto('{manifest_path.as_posix()}')")
    print("  raw_tlc.taxi_zones, raw_weather.central_park_daily, raw_tlc._extract_manifest")
    con.close()


if __name__ == "__main__":
    main()
