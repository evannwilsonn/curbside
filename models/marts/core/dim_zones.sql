select
    zone_id,
    zone_name,
    coalesce(borough, 'Unknown')                         as borough,
    coalesce(service_zone, 'Unknown')                    as service_zone,
    is_airport,
    -- Manhattan below 60th Street is the congestion relief zone (approximated by TLC zone)
    borough = 'Manhattan' and service_zone = 'Yellow Zone' as in_core_manhattan
from {{ ref('stg_tlc__zones') }}
