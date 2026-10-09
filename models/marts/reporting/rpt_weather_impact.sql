-- How weather moves demand. Each day is compared with dry days of the same kind
-- (weekday vs weekend) so the weekly pattern doesn't masquerade as a weather effect.
with base as (
    select
        is_weekend,
        avg(case when weather_type = 'Dry' then trips end) as dry_trips
    from {{ ref('rpt_kpi_daily') }}
    where not is_holiday
    group by 1
)
select
    d.weather_type,
    count(*)                                                       as days,
    avg(d.trips)                                                   as avg_trips,
    avg(d.trips / b.dry_trips) - 1                                 as trips_vs_dry,
    avg(d.avg_speed_mph)                                           as avg_speed_mph,
    avg(d.card_tip_rate)                                           as card_tip_rate
from {{ ref('rpt_kpi_daily') }} as d
join base as b using (is_weekend)
where not d.is_holiday
group by 1
