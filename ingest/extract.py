"""
Extract: pull NYC taxi trip records, the taxi zone map and daily weather into data/raw.

  * NYC TLC trip records (official, published monthly as Parquet by the NYC Taxi & Limousine
    Commission): yellow taxis and green "boro" taxis, January 2025 through July 2026.
    That window starts with congestion pricing (January 5, 2025) and gives a full
    year-over-year comparison for 2026.
  * TLC taxi zone lookup: the 265 zones trips are coded to, with borough and service zone.
  * Daily weather for Central Park from the Open-Meteo historical archive.

Each file is written exactly as downloaded, and a manifest records URL, bytes, row count
and SHA-256, so every number on the dashboard traces back to a file.

    python ingest/extract.py            # download (about 1.3 GB, skips files already present)
    python ingest/extract.py --offline  # rebuild the manifest from files on disk
"""
from __future__ import annotations

import argparse
import hashlib
import json
import time
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
TLC = "https://d37ci6vzurychx.cloudfront.net"
MONTHS = [f"{y}-{m:02d}" for y in (2025, 2026) for m in range(1, 13) if (y, m) <= (2026, 7)]
WEATHER = ("https://archive-api.open-meteo.com/v1/archive?latitude=40.7812&longitude=-73.9665"
           "&start_date=2025-01-01&end_date=2026-07-31&timezone=America%2FNew_York"
           "&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,snowfall_sum,wind_speed_10m_max"
           "&temperature_unit=fahrenheit&precipitation_unit=inch&wind_speed_unit=mph")


def fetch(url: str, attempts: int = 5) -> bytes:
    for i in range(attempts):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "curbside-extract/1.0"})
            with urllib.request.urlopen(req, timeout=300) as r:
                return r.read()
        except Exception as exc:
            if i == attempts - 1:
                raise SystemExit(f"Failed to fetch {url}: {exc}")
            time.sleep(2 ** i)
    raise AssertionError


def parquet_rows(path: Path) -> int:
    import duckdb
    return duckdb.sql(f"select count(*) from read_parquet('{path.as_posix()}')").fetchone()[0]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--offline", action="store_true")
    args = ap.parse_args()
    targets = []
    for service in ("yellow", "green"):
        for m in MONTHS:
            targets.append((f"tlc/{service}_tripdata_{m}.parquet", f"{TLC}/trip-data/{service}_tripdata_{m}.parquet", service))
    targets.append(("tlc/taxi_zone_lookup.csv", f"{TLC}/misc/taxi_zone_lookup.csv", "zones"))
    targets.append(("weather/central_park_daily.json", WEATHER, "weather"))

    manifest = []
    for rel, url, kind in targets:
        out = RAW / rel
        out.parent.mkdir(parents=True, exist_ok=True)
        if not out.exists():
            if args.offline:
                raise SystemExit(f"--offline but {rel} is missing")
            out.write_bytes(fetch(url))
        body = out.read_bytes()
        if out.suffix == ".parquet":
            rows = parquet_rows(out)
        elif out.suffix == ".csv":
            rows = body.count(b"\n") - 1
        else:
            rows = len(json.loads(body)["daily"]["time"])
        manifest.append({"file": rel, "kind": kind, "url": url, "bytes": len(body), "rows": rows,
                         "sha256": hashlib.sha256(body).hexdigest(),
                         "fetched_at": datetime.now(timezone.utc).isoformat(timespec="seconds")})
        print(f"  {rel:<44} {rows:>10,} rows  {len(body) / 1e6:>7.1f} MB")
    (RAW / "_manifest.json").write_text(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
