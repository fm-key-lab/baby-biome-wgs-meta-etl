{{ config(materialized='table') }}

with cleaned_timepoints as (
    select
        isolate_id,
        timepoint,
        if(
            approx_days is null,
            null,
            cast(
                round(approx_days) || ' days' 
                as interval
            )
        ) as timepoint_interval
    from (
        select
            isolate_id,
            case
                -- before
                when unit = 'before' then -1
                -- months, 1 day ~= (365 * 4 + 1) / (12 * 4)
                when unit = 'months' then unit_val * ((365 * 4 + 1) / (12 * 4))
                -- weeks
                when unit = 'weeks' then unit_val * 7
                else -100
            end
            as approx_days,
            
            -- Keep a stdized categorical variable for timepoint
            case
                -- before
                when unit = 'before' then 'before'
                when unit is null or unit_val is null then null
                else concat_ws(
                    '_', cast(unit_val as varchar), unit
                )
            end
            as timepoint
        from (
            select
                isolate_id,
                regexp_extract(
                    timepoint, '(\D+)$', 1
                ) as unit_raw,
                case
                    -- before
                    when unit_raw ilike 'vor' then 'before'
                    when unit_raw ilike 'before' then 'before'
            
                    -- months
                    when unit_raw ilike 'm' then 'months'
                    when unit_raw ilike 'monate' then 'months'
                    when unit_raw ilike 'months' then 'months'
            
                    -- weeks
                    when unit_raw ilike 'w' then 'weeks'
                    when unit_raw ilike 'wochen' then 'weeks'
                    when unit_raw ilike 'weeks' then 'weeks'
                    else unit_raw
                end as unit,
                try_cast(
                    regexp_extract(timepoint, '^(\d+)', 1) as usmallint
                ) as unit_val
            from {{ ref("stg_samplesheets__isolates") }}
        )
    )
)
-- No conflicting metadata found, so use `any_value()`
select
    isolate_id,
    any_value(timepoint) as timepoint,
    any_value(timepoint_interval) as timepoint_interval,
from cleaned_timepoints
group by isolate_id