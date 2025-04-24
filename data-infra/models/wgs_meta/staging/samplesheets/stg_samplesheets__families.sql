{{ config(materialized='table') }}

with cleaned_families as (
    select
        isolate_id,
        -- Base model fills `family` with nulls if not present
        coalesce(
            nullif(family, ''),
            regexp_extract(
                isolate_id, '([BP]\d+|Ctr\d+|Control\d+)_\d+', 1
            )
        ) as family
    from {{ ref("stg_samplesheets__isolates") }}
)
-- No conflicting metadata found, so use `any_value()`
select
    isolate_id,
    any_value(family) as family,
from cleaned_families
group by isolate_id