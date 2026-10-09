-- Load the extracted files into Snowflake: the same raw landing zone the DuckDB loader builds.
-- 1) Run `python ingest/extract.py` locally.
-- 2) Run this file with SnowSQL from the project folder (PUT needs a client, not a worksheet):
--      snowsql -a <account> -u <user> -f ingest/snowflake_load.sql
-- Parquet columns keep their types (names upper-cased so dbt's unquoted references resolve);
-- MATCH_BY_COLUMN_NAME absorbs TLC's schema drift between months.

create database if not exists curbside;
use database curbside;
create schema if not exists raw_tlc;
create schema if not exists raw_weather;
use schema raw_tlc;

create or replace file format parquet_ff type = parquet;
create or replace file format csv_ff type = csv parse_header = true field_optionally_enclosed_by = '"';
create or replace file format json_ff type = json;
create or replace stage tlc_stage;
put file://data/raw/tlc/*.parquet @tlc_stage/trips/ auto_compress = false overwrite = true;
put file://data/raw/tlc/taxi_zone_lookup.csv @tlc_stage/zones/ overwrite = true;
put file://data/raw/weather/central_park_daily.json @tlc_stage/weather/ overwrite = true;
put file://data/raw/_manifest.json @tlc_stage/manifest/ overwrite = true;

-- one table per service, schema from the newest file so every column exists
create or replace table yellow_trips using template (
  select array_agg(object_construct('COLUMN_NAME', upper(column_name), 'TYPE', type, 'NULLABLE', true)) from table(infer_schema(
    location => '@tlc_stage/trips/yellow_tripdata_2026-07.parquet', file_format => 'parquet_ff')));
alter table yellow_trips add column _source_file varchar, _loaded_at timestamp_ntz;
copy into yellow_trips from @tlc_stage/trips/ pattern = '.*yellow_tripdata_.*[.]parquet'
  file_format = (format_name = 'parquet_ff') match_by_column_name = case_insensitive
  include_metadata = (_source_file = metadata$filename, _loaded_at = metadata$start_scan_time);

create or replace table green_trips using template (
  select array_agg(object_construct('COLUMN_NAME', upper(column_name), 'TYPE', type, 'NULLABLE', true)) from table(infer_schema(
    location => '@tlc_stage/trips/green_tripdata_2026-07.parquet', file_format => 'parquet_ff')));
alter table green_trips add column _source_file varchar, _loaded_at timestamp_ntz;
copy into green_trips from @tlc_stage/trips/ pattern = '.*green_tripdata_.*[.]parquet'
  file_format = (format_name = 'parquet_ff') match_by_column_name = case_insensitive
  include_metadata = (_source_file = metadata$filename, _loaded_at = metadata$start_scan_time);

-- metadata$filename includes the stage folder; keep only the file name, like the DuckDB loader
update yellow_trips set _source_file = regexp_substr(_source_file, '[^/]+$');
update green_trips set _source_file = regexp_substr(_source_file, '[^/]+$');

create or replace table taxi_zones (LocationID varchar, Borough varchar, Zone varchar, service_zone varchar,
                                    _source_file varchar, _loaded_at timestamp_ntz);
copy into taxi_zones from (select $1, $2, $3, $4, 'taxi_zone_lookup.csv', current_timestamp() from @tlc_stage/zones/)
  file_format = (type = csv skip_header = 1 field_optionally_enclosed_by = '"');

create or replace table raw_weather.central_park_daily (payload variant, _source_file varchar, _loaded_at timestamp_ntz);
copy into raw_weather.central_park_daily from (select $1, 'central_park_daily.json', current_timestamp() from @tlc_stage/weather/)
  file_format = (format_name = 'json_ff');

create or replace table "_EXTRACT_MANIFEST" as
select f.value:"file"::varchar as "file", f.value:"kind"::varchar as "kind", f.value:"url"::varchar as "url",
       f.value:"rows"::integer as "rows", f.value:"bytes"::integer as "bytes", f.value:"sha256"::varchar as "sha256"
from @tlc_stage/manifest/ (file_format => 'json_ff') t, lateral flatten(input => t.$1) f;
