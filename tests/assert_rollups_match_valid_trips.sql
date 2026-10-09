-- The daily and hourly rollups each contain exactly the valid trips in the reporting window.
with v as (
    select count(*) as n, sum(total_amount) as rev
    from {{ ref('int_trips__validated') }}
    where exclusion_reason is null
      and pickup_date between cast('{{ var("report_start") }}' as date) and cast('{{ var("report_end") }}' as date)
),
d as (select sum(trips) as n, sum(gross_revenue) as rev from {{ ref('fct_trips_daily') }}),
h as (select sum(trips) as n from {{ ref('fct_trips_hourly') }})
select v.n, d.n as daily_n, h.n as hourly_n
from v cross join d cross join h
where v.n <> d.n or v.n <> h.n or abs(v.rev - d.rev) > 1
