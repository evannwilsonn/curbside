-- The archive returns parallel arrays (one per variable); unnest them into one row per day.
{%- if target.type == 'snowflake' %}
select
    to_date(t.value::varchar)                                       as weather_date,
    payload:daily:temperature_2m_max[t.index]::float               as temp_max_f,
    payload:daily:temperature_2m_min[t.index]::float               as temp_min_f,
    payload:daily:precipitation_sum[t.index]::float                as precip_in,
    payload:daily:snowfall_sum[t.index]::float                     as snow_in,
    payload:daily:wind_speed_10m_max[t.index]::float               as wind_max_mph
from {{ source('weather', 'central_park_daily') }},
     lateral flatten(input => payload:daily:time) as t
{%- else %}
with d as (
    select
        cast(json_extract(payload, '$.daily.time') as varchar[])                as dt,
        cast(json_extract(payload, '$.daily.temperature_2m_max') as double[])  as tmax,
        cast(json_extract(payload, '$.daily.temperature_2m_min') as double[])  as tmin,
        cast(json_extract(payload, '$.daily.precipitation_sum') as double[])   as prcp,
        cast(json_extract(payload, '$.daily.snowfall_sum') as double[])        as snow,
        cast(json_extract(payload, '$.daily.wind_speed_10m_max') as double[])  as wind
    from {{ source('weather', 'central_park_daily') }}
)
select
    cast(dt[i] as date)  as weather_date,
    tmax[i]              as temp_max_f,
    tmin[i]              as temp_min_f,
    prcp[i]              as precip_in,
    snow[i]              as snow_in,
    wind[i]              as wind_max_mph
from d, range(1, len(dt) + 1) as r(i)
{%- endif %}
