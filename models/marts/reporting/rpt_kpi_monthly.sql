-- The executive scorecard in long format: one row per KPI per month with the prior month,
-- the same month last year, the target and a status. Status direction comes from the KPI catalog
-- (for trip time, lower is better).
{%- set kpis = ['trips','gross_revenue','revenue_per_trip','fare_per_mile','avg_speed_mph','avg_trip_minutes',
                'airport_share','card_tip_rate','cbd_fee_revenue','green_share','valid_record_rate'] %}
with wide as (
    select * from {{ ref('int_kpis__monthly') }}
    where month_start between cast('{{ var("report_start") }}' as date) and cast('{{ var("report_end") }}' as date)
),

long as (
    {%- for k in kpis %}
    select month_start, '{{ k }}' as kpi_id, cast({{ k }} as double) as value from wide
    {%- if not loop.last %} union all{% endif %}
    {%- endfor %}
),

compared as (
    select
        cur.month_start,
        cur.kpi_id,
        cur.value,
        pm.value as prior_month_value,
        py.value as prior_year_value
    from long as cur
    left join long as pm on pm.kpi_id = cur.kpi_id and pm.month_start = {{ add_months('cur.month_start', -1) }}
    left join long as py on py.kpi_id = cur.kpi_id and py.month_start = {{ add_months('cur.month_start', -12) }}
),

targeted as (
    select
        c.*,
        d.kpi_name,
        d.category,
        d.unit,
        d.direction,
        d.sort_order,
        case d.target_type
            when 'absolute'   then d.target_value
            when 'yoy_growth' then c.prior_year_value * (1 + d.target_value)
            else null
        end as target
    from compared as c
    join {{ ref('kpi_definitions') }} as d using (kpi_id)
)

select
    month_start,
    kpi_id,
    kpi_name,
    category,
    unit,
    direction,
    sort_order,
    value,
    prior_month_value,
    prior_year_value,
    value / nullif(prior_month_value, 0) - 1   as change_mom,
    value / nullif(prior_year_value, 0) - 1    as change_yoy,
    target,
    case
        when target is null then null
        when direction = 'up'   and value >= target                                   then 'On track'
        when direction = 'up'   and value >= target * (1 - {{ var('watch_band') }})   then 'Watch'
        when direction = 'down' and value <= target                                   then 'On track'
        when direction = 'down' and value <= target * (1 + {{ var('watch_band') }})   then 'Watch'
        else 'Off track'
    end as status
from targeted
where month_start between cast('{{ var("report_start") }}' as date) and cast('{{ var("report_end") }}' as date)
