# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Hiring managers first, arriving from Evan Wilson's resume or LinkedIn and giving the page about a minute; they need to see an executive KPI dashboard on real, very large data, fed by a pipeline they can trust. Analytics and data engineers second, who check the KPI definitions, targets, validation rules and grain. Desktop and phone viewing are about equal. (Confirmed for the whole portfolio on 2026-10-09.)

## Product Purpose

Curbside is an end-to-end analytics pipeline and executive KPI dashboard on 76 million NYC Taxi & Limousine Commission yellow and green taxi trip records (Jan 2025 to Jul 2026), with daily Central Park weather and the taxi zone map. Ten validation rules decide which records count (69.1M of 76.0M pass); dbt builds a star schema and a governed KPI scorecard with definitions, targets, month-over-month and year-over-year comparisons. The dashboard answers "how is the NYC taxi business doing this month against target, and why": demand, revenue, operations, rider experience and data quality, with drill-downs by borough, zone, hour and weather.

## Positioning

The executive dashboard and the pipeline behind it in one project, at real scale (76M rows, 1.3 GB, 40 source files with checksums), with KPI definitions and targets governed as data and a visible account of what validation excluded.

## Operating Context

Static page with inline data (dashboard/data.json), built from DuckDB or Snowflake; also published as a Claude artifact.

## Capabilities and Constraints

- Data: KPI catalog (11 KPIs, definitions, units, direction, target type and value), monthly KPI values with prior month, prior year, target and status (On track / Watch / Off track / none), daily trips and revenue with weather and holidays, boroughs and top zones by month, average trips and speed by weekday and hour, weather effects, data-quality outcomes by month, pipeline totals.
- 19 months, latest Jul 2026. Congestion pricing fees exist from Jan 2025.
- Every number comes from data.json.

## Brand Commitments

Each portfolio project has its own visual world and its own new colour palette, distinct from Reprise (cool white, ink, blue ramp, amber), Cloverfield (control-room black, Caltrans orange, green/amber/red), Cloverleaf (concrete grey, plum, lime), Switchyard (cream, rust, umber) and the earlier IBM Plex blue and sign-green looks.

## Evidence on Hand

dashboard/data.json; README tables of validation exclusions. No users or testimonials.

## Product Principles

1. The month's verdict first: which KPIs are on and off target, and by how much.
2. Every KPI shows its definition and target on demand.
3. What was excluded is shown, not hidden.
4. Every mark maps to real data.

## Accessibility & Inclusion

WCAG AA contrast in light and dark; status never carried by colour alone; works at phone width.
