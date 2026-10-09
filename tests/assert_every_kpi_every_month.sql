select month_start, count(*) as kpis
from {{ ref('rpt_kpi_monthly') }}
group by 1
having count(*) <> (select count(*) from {{ ref('kpi_definitions') }})
