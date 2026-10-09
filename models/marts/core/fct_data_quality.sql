-- Raw records by file month and exclusion reason, so every excluded trip is accounted for.
select
    file_month,
    service,
    coalesce(exclusion_reason, 'valid')   as status,
    count(*)                              as records,
    sum(total_amount)                     as total_amount
from {{ ref('int_trips__validated') }}
group by 1, 2, 3
