-- The 25 busiest pickup zones each month.
with z as (
    select
        f.pickup_month                                 as month_start,
        f.pickup_zone_id                               as zone_id,
        d.zone_name,
        d.borough,
        sum(f.trips)                                   as trips,
        sum(f.gross_revenue)                           as gross_revenue,
        sum(f.gross_revenue) / sum(f.trips)            as revenue_per_trip
    from {{ ref('fct_trips_daily') }} as f
    join {{ ref('dim_zones') }} as d on d.zone_id = f.pickup_zone_id
    group by 1, 2, 3, 4
)
select *
from z
qualify row_number() over (partition by month_start order by trips desc, zone_id) <= 25
