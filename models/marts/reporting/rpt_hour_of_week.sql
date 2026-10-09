-- Average trips per hour and speed by weekday and hour, for each month (one dashboard edition per month).
with h as (
    select
        {{ month_start('f.pickup_date') }}             as month_start,
        f.pickup_date,
        {{ weekday_of('f.pickup_date') }}               as weekday_num,
        f.pickup_hour,
        sum(f.trips)                                   as trips,
        sum(f.miles)                                   as miles,
        sum(f.minutes)                                 as minutes
    from {{ ref('fct_trips_hourly') }} as f
    group by 1, 2, 3, 4
)
select
    month_start,
    weekday_num,
    pickup_hour,
    avg(trips)                                         as avg_trips,
    sum(miles) / (sum(minutes) / 60.0)                 as avg_speed_mph
from h
group by 1, 2, 3
