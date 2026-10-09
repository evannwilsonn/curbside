-- Yellow and green trips in one shape. Column names differ by service (tpep_ vs lpep_),
-- green has no airport fee, and newer files add columns, so each side is mapped explicitly.
{%- set common = "passenger_count, trip_distance, PULocationID, DOLocationID, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, congestion_surcharge, cbd_congestion_fee, _source_file" %}
select
    'yellow'                                  as service,
    VendorID                                  as vendor_id,
    tpep_pickup_datetime                      as pickup_at,
    tpep_dropoff_datetime                     as dropoff_at,
    cast(RatecodeID as integer)               as rate_code,
    cast(passenger_count as integer)          as passenger_count,
    trip_distance                             as trip_miles,
    PULocationID                              as pickup_zone_id,
    DOLocationID                              as dropoff_zone_id,
    cast(payment_type as integer)             as payment_type,
    fare_amount,
    tip_amount,
    tolls_amount,
    total_amount,
    coalesce(congestion_surcharge, 0)         as congestion_surcharge,
    coalesce(cbd_congestion_fee, 0)           as cbd_congestion_fee,
    coalesce(airport_fee, 0)                  as airport_fee,
    -- the file's month, from its name (e.g. yellow_tripdata_2026-07.parquet)
    cast(substr(_source_file, length(_source_file) - 14, 7) || '-01' as date) as file_month,
    _source_file
from {{ source('tlc', 'yellow_trips') }}

union all

select
    'green',
    VendorID,
    lpep_pickup_datetime,
    lpep_dropoff_datetime,
    cast(RatecodeID as integer),
    cast(passenger_count as integer),
    trip_distance,
    PULocationID,
    DOLocationID,
    cast(payment_type as integer),
    fare_amount,
    tip_amount,
    tolls_amount,
    total_amount,
    coalesce(congestion_surcharge, 0),
    coalesce(cbd_congestion_fee, 0),
    0,
    cast(substr(_source_file, length(_source_file) - 14, 7) || '-01' as date),
    _source_file
from {{ source('tlc', 'green_trips') }}
