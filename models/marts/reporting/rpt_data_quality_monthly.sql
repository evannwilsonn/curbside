-- Raw records by month and outcome: valid, or the first rule they failed.
select
    file_month                                                   as month_start,
    status,
    sum(records)                                                 as records,
    sum(records) * 1.0 / sum(sum(records)) over (partition by file_month) as share_of_month
from {{ ref('fct_data_quality') }}
group by 1, 2
