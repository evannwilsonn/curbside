-- Pickups by borough and month.
select
    f.pickup_month                                     as month_start,
    z.borough,
    sum(f.trips)                                       as trips,
    sum(f.gross_revenue)                               as gross_revenue,
    sum(f.gross_revenue) / sum(f.trips)                as revenue_per_trip,
    sum(f.miles) / (sum(f.minutes) / 60.0)             as avg_speed_mph
from {{ ref('fct_trips_daily') }} as f
join {{ ref('dim_zones') }} as z on z.zone_id = f.pickup_zone_id
group by 1, 2
