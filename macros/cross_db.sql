{#- Cross-database helpers: every model runs unchanged on DuckDB (local) and Snowflake. -#}

{% macro minutes_between(start_ts, end_ts) -%}{{ return(adapter.dispatch('minutes_between')(start_ts, end_ts)) }}{%- endmacro %}
{% macro duckdb__minutes_between(start_ts, end_ts) -%}((epoch({{ end_ts }}) - epoch({{ start_ts }})) / 60.0){%- endmacro %}
{% macro snowflake__minutes_between(start_ts, end_ts) -%}(datediff(second, {{ start_ts }}, {{ end_ts }}) / 60.0){%- endmacro %}

{% macro add_months(column, n) -%}{{ return(adapter.dispatch('add_months')(column, n)) }}{%- endmacro %}
{% macro duckdb__add_months(column, n) -%}cast({{ column }} + to_months({{ n }}) as date){%- endmacro %}
{% macro snowflake__add_months(column, n) -%}dateadd(month, {{ n }}, {{ column }}){%- endmacro %}

{% macro hour_of(ts) -%}{{ return(adapter.dispatch('hour_of')(ts)) }}{%- endmacro %}
{% macro duckdb__hour_of(ts) -%}hour({{ ts }}){%- endmacro %}
{% macro snowflake__hour_of(ts) -%}hour({{ ts }}){%- endmacro %}

{# 0 = Monday ... 6 = Sunday on both engines #}
{% macro weekday_of(d) -%}{{ return(adapter.dispatch('weekday_of')(d)) }}{%- endmacro %}
{% macro duckdb__weekday_of(d) -%}((dayofweek({{ d }}) + 6) % 7){%- endmacro %}
{% macro snowflake__weekday_of(d) -%}(dayofweekiso({{ d }}) - 1){%- endmacro %}

{% macro month_start(column) -%}cast(date_trunc('month', {{ column }}) as date){%- endmacro %}

{# Read a JSON array element from a VARIANT/JSON payload #}
{% macro json_array(col, path) -%}{{ return(adapter.dispatch('json_array')(col, path)) }}{%- endmacro %}
{% macro duckdb__json_array(col, path) -%}json_extract({{ col }}, '$.{{ path }}'){%- endmacro %}
{% macro snowflake__json_array(col, path) -%}{{ col }}:{{ path }}{%- endmacro %}
