{{ config(materialized='table') }}

with cleaned_relationships as (
    select
        isolate_id,
        rtrim(relationship) as __relationship,
        case
            -- baby (focal)
            when __relationship like 'B%' then 'baby'
            when __relationship ilike 'baby%' then 'baby'

            -- sibling
            when __relationship ilike 'kind%' then 'sibling'
            when __relationship ilike 'sibling%' then 'sibling'

            -- mother
            when __relationship like 'M%' then 'mother'
            when __relationship ilike 'mutter' then 'mother'
            when __relationship ilike 'mother' then 'mother'

            -- father
            when __relationship like 'V%' then 'father'
            when __relationship ilike 'vater' then 'father'
            when __relationship ilike 'father' then 'father'

            else null
        end as relationship
    from {{ ref("stg_samplesheets__isolates") }}
)
-- No conflicting metadata found, so use `any_value()`
select
    isolate_id,
    any_value(relationship) as relationship,
from cleaned_relationships
group by isolate_id