-- Average trips per hour and speed by weekday and hour, over the latest three months.
with h as (
    select
        f.pickup_date,
        {{ weekday_of('f.pickup_date') }}               as weekday_num,
        f.pickup_hour,
        sum(f.trips)                                   as trips,
        sum(f.miles)                                   as miles,
        sum(f.minutes)                                 as minutes
    from {{ ref('fct_trips_hourly') }} as f
    where f.pickup_date > {{ add_months("cast('" ~ var('report_end') ~ "' as date)", -3) }}
    group by 1, 2, 3
)
select
    weekday_num,
    pickup_hour,
    avg(trips)                                         as avg_trips,
    sum(miles) / (sum(minutes) / 60.0)                 as avg_speed_mph
from h
group by 1, 2
