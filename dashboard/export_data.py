"""
Export the reporting marts the dashboard reads into dashboard/data.json.

Run after `dbt build`:  python dashboard/export_data.py
"""
from __future__ import annotations

import json
from datetime import date, datetime
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "warehouse" / "curbside.duckdb"
OUT = ROOT / "dashboard" / "data.json"


def clean(v):
    if isinstance(v, datetime):
        return v.isoformat()[:10]
    if isinstance(v, date):
        return v.isoformat()
    if isinstance(v, float):
        return round(v, 5)
    if hasattr(v, "as_tuple"):
        return round(float(v), 5)
    return v


def table(con, sql):
    cur = con.execute(sql)
    return {"columns": [d[0] for d in cur.description], "rows": [[clean(v) for v in r] for r in cur.fetchall()]}


def main() -> None:
    con = duckdb.connect(str(DB), read_only=True)
    con.execute("set enable_progress_bar = false")
    one = lambda sql: clean(con.execute(sql).fetchone()[0])
    payload = {
        "generated": date.today().isoformat(),
        "kpi_catalog": table(con, "select kpi_id, kpi_name, category, definition, unit, direction, target_type, target_value from reference.kpi_definitions order by sort_order"),
        "kpis": table(con, "select strftime(month_start, '%Y-%m') as month, kpi_id, value, prior_month_value, prior_year_value, target, status from reporting.rpt_kpi_monthly order by 1, 2"),
        "daily": table(con, "select date_day, trips, gross_revenue, weather_type, is_holiday, holiday_name, precip_in, snow_in from reporting.rpt_kpi_daily order by 1"),
        "boroughs": table(con, "select strftime(month_start, '%Y-%m') as month, borough, trips, gross_revenue, revenue_per_trip, avg_speed_mph from reporting.rpt_borough_monthly order by 1, 3 desc"),
        "zones": table(con, "select strftime(month_start, '%Y-%m') as month, zone_name, borough, trips, revenue_per_trip from reporting.rpt_zone_monthly order by 1, 4 desc"),
        "hours": table(con, "select weekday_num, pickup_hour, avg_trips, avg_speed_mph from reporting.rpt_hour_of_week order by 1, 2"),
        "weather": table(con, "select weather_type, days, avg_trips, trips_vs_dry, avg_speed_mph, card_tip_rate from reporting.rpt_weather_impact"),
        "dq": table(con, "select strftime(month_start, '%Y-%m') as month, status, records, share_of_month from reporting.rpt_data_quality_monthly order by 1, 3 desc"),
        "pipeline": {
            "files": one("select count(*) from raw_tlc._extract_manifest"),
            "gigabytes": one("select sum(bytes) / 1e9 from raw_tlc._extract_manifest"),
            "raw_records": one("select sum(records) from core.fct_data_quality"),
            "valid_records": one("select sum(records) from core.fct_data_quality where status = 'valid'"),
            "rules": one("select count(distinct status) - 1 from core.fct_data_quality"),
        },
    }
    OUT.write_text(json.dumps(payload, separators=(",", ":")))
    print(f"Wrote {OUT.relative_to(ROOT)} ({OUT.stat().st_size / 1024:.0f} KB)")


if __name__ == "__main__":
    main()
