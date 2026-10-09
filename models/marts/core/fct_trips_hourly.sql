-- Valid trips by day and hour of pickup, for time-of-week patterns.
select
    pickup_date,
    pickup_hour,
    service,
    count(*)            as trips,
    sum(total_amount)   as gross_revenue,
    sum(trip_miles)     as miles,
    sum(trip_minutes)   as minutes
from {{ ref('int_trips__validated') }}
where exclusion_reason is null
  and pickup_date between cast('{{ var("report_start") }}' as date) and cast('{{ var("report_end") }}' as date)
group by 1, 2, 3
