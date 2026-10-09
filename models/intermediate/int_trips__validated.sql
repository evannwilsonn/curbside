-- Every trip with derived measures and its first data-quality problem, if any.
-- Trips are never deleted here: excluded rows keep their reason so the exclusions can be counted.
with t as (
    select
        s.*,
        {{ minutes_between('s.pickup_at', 's.dropoff_at') }} as trip_minutes
    from {{ ref('stg_tlc__trips') }} as s
)

select
    t.service,
    t.pickup_at,
    cast(t.pickup_at as date)                                         as pickup_date,
    {{ month_start('t.pickup_at') }}                                  as pickup_month,
    {{ hour_of('t.pickup_at') }}                                      as pickup_hour,
    t.file_month,
    t.pickup_zone_id,
    t.dropoff_zone_id,
    t.payment_type,
    coalesce(t.rate_code, 99)                                         as rate_code,
    t.passenger_count,
    t.trip_miles,
    t.trip_minutes,
    case when t.trip_minutes > 0 then t.trip_miles / (t.trip_minutes / 60.0) end as avg_mph,
    t.fare_amount,
    t.tip_amount,
    t.tolls_amount,
    t.total_amount,
    t.congestion_surcharge,
    t.cbd_congestion_fee,
    t.airport_fee,
    case
        when {{ month_start('t.pickup_at') }} <> t.file_month              then 'pickup outside file month'
        when t.trip_minutes <= 0                                           then 'drop-off not after pickup'
        when t.trip_minutes > {{ var('max_trip_hours') }} * 60             then 'trip over 6 hours'
        when t.payment_type in (3, 4, 6)                                   then 'no charge, dispute or void'
        when t.total_amount < 0 or t.fare_amount < 0                       then 'negative amount'
        when t.total_amount = 0                                            then 'zero total'
        when t.trip_miles <= 0                                             then 'zero distance'
        when t.trip_miles > {{ var('max_trip_miles') }}                    then 'distance over 100 miles'
        when t.trip_miles / (t.trip_minutes / 60.0) > {{ var('max_avg_mph') }} then 'average speed over 80 mph'
        when t.pickup_zone_id in (264, 265) or t.pickup_zone_id is null   then 'unknown pickup zone'
    end                                                               as exclusion_reason
from t
