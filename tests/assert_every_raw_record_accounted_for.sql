-- Every raw record is either valid or excluded with a reason: nothing is silently dropped.
with raw as (
    select (select count(*) from {{ source('tlc', 'yellow_trips') }})
         + (select count(*) from {{ source('tlc', 'green_trips') }}) as n
),
dq as (select sum(records) as n from {{ ref('fct_data_quality') }})
select raw.n as raw_records, dq.n as accounted
from raw cross join dq
where raw.n <> dq.n
