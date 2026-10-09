-- Rows per file in the warehouse match what the extractor counted when it downloaded the file.
with loaded as (
    select _source_file, count(*) as n from {{ source('tlc', 'yellow_trips') }} group by 1
    union all
    select _source_file, count(*) from {{ source('tlc', 'green_trips') }} group by 1
)
select l._source_file, l.n, m."rows" as manifest_rows
from loaded as l
join {{ source('tlc', '_extract_manifest') }} as m on m."file" = 'tlc/' || l._source_file
where l.n <> m."rows"
