-- Valid trips rolled up to day x pickup zone x service x payment type.
-- At 75M+ trips this is the grain the dashboard and every KPI read from.
select
    pickup_date,
    pickup_month,
    service,
    pickup_zone_id,
    payment_type,
    count(*)                                                     as trips,
    sum(total_amount)                                            as gross_revenue,
    sum(fare_amount)                                             as fare_revenue,
    sum(tip_amount)                                              as tips,
    sum(case when payment_type = 1 then tip_amount else 0 end)   as card_tips,
    sum(case when payment_type = 1 then fare_amount else 0 end)  as card_fares,
    sum(tolls_amount)                                            as tolls,
    sum(cbd_congestion_fee)                                      as cbd_fees,
    sum(case when cbd_congestion_fee > 0 then 1 else 0 end)      as cbd_trips,
    sum(case when airport_fee > 0 or rate_code in (2, 3) then 1 else 0 end) as airport_trips,
    sum(trip_miles)                                              as miles,
    sum(trip_minutes)                                            as minutes
from {{ ref('int_trips__validated') }}
where exclusion_reason is null
  and pickup_date between cast('{{ var("report_start") }}' as date) and cast('{{ var("report_end") }}' as date)
group by 1, 2, 3, 4, 5
