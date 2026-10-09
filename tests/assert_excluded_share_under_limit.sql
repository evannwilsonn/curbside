-- Data quality gate: no month may lose more than max_excluded_share of its raw records to validation.
select month_start, sum(share_of_month) as excluded_share
from {{ ref('rpt_data_quality_monthly') }}
where status <> 'valid'
group by 1
having sum(share_of_month) > {{ var('max_excluded_share') }}
