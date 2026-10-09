-- Daily totals with weather, for the trend line and weather analysis.
select
    d.date_day,
    d.weekday_num,
    d.is_weekend,
    d.is_holiday,
    d.holiday_name,
    d.weather_type,
    d.precip_in,
    d.snow_in,
    d.temp_max_f,
    sum(f.trips)                                       as trips,
    sum(f.gross_revenue)                               as gross_revenue,
    sum(f.miles) / (sum(f.minutes) / 60.0)             as avg_speed_mph,
    sum(f.card_tips) / nullif(sum(f.card_fares), 0)    as card_tip_rate
from {{ ref('dim_date') }} as d
join {{ ref('fct_trips_daily') }} as f on f.pickup_date = d.date_day
group by 1, 2, 3, 4, 5, 6, 7, 8, 9
