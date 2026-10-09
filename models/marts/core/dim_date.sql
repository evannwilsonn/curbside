-- One row per day in the reporting window, with weather and holidays attached.
select
    w.weather_date                                        as date_day,
    {{ month_start('w.weather_date') }}                   as month_start,
    {{ weekday_of('w.weather_date') }}                    as weekday_num,
    {{ weekday_of('w.weather_date') }} >= 5               as is_weekend,
    h.holiday_name,
    h.holiday_name is not null                            as is_holiday,
    w.temp_max_f,
    w.temp_min_f,
    w.precip_in,
    w.snow_in,
    w.wind_max_mph,
    case
        when w.snow_in >= 1      then 'Snow'
        when w.precip_in >= 0.5  then 'Heavy rain'
        when w.precip_in >= 0.05 then 'Light rain'
        else 'Dry'
    end                                                   as weather_type
from {{ ref('stg_weather__daily') }} as w
left join {{ ref('holidays') }} as h on h.holiday_date = w.weather_date
where w.weather_date between cast('{{ var("report_start") }}' as date) and cast('{{ var("report_end") }}' as date)
