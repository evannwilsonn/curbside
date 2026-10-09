select
    cast(LocationID as integer)                   as zone_id,
    nullif(trim(Borough), 'N/A')                  as borough,
    trim(Zone)                                    as zone_name,
    nullif(trim(service_zone), 'N/A')             as service_zone,
    cast(LocationID as integer) in (1, 132, 138)  as is_airport
from {{ source('tlc', 'taxi_zones') }}
