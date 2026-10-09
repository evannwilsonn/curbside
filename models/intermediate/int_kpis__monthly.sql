-- Every KPI for every month, wide. Definitions live in seeds/kpi_definitions.csv; this is the
-- only place they are computed, so the scorecard, trend and brief can never disagree.
{{ config(materialized='view') }}
with t as (
    select
        pickup_month                                                      as month_start,
        sum(trips)                                                        as trips,
        sum(gross_revenue)                                                as gross_revenue,
        sum(fare_revenue)                                                 as fare_revenue,
        sum(card_tips)                                                    as card_tips,
        sum(card_fares)                                                   as card_fares,
        sum(cbd_fees)                                                     as cbd_fees,
        sum(airport_trips)                                                as airport_trips,
        sum(case when service = 'green' then trips else 0 end)            as green_trips,
        sum(miles)                                                        as miles,
        sum(minutes)                                                      as minutes
    from {{ ref('fct_trips_daily') }}
    group by 1
),

dq as (
    select
        file_month                                                        as month_start,
        sum(case when status = 'valid' then records else 0 end) * 1.0 / sum(records) as valid_record_rate
    from {{ ref('fct_data_quality') }}
    group by 1
)

select
    t.month_start,
    cast(t.trips as double)                    as trips,
    t.gross_revenue,
    t.gross_revenue / t.trips                  as revenue_per_trip,
    t.fare_revenue / t.miles                   as fare_per_mile,
    t.miles / (t.minutes / 60.0)               as avg_speed_mph,
    t.minutes / t.trips                        as avg_trip_minutes,
    t.airport_trips * 1.0 / t.trips            as airport_share,
    t.card_tips / t.card_fares                 as card_tip_rate,
    t.cbd_fees                                 as cbd_fee_revenue,
    t.green_trips * 1.0 / t.trips              as green_share,
    dq.valid_record_rate
from t
join dq using (month_start)
