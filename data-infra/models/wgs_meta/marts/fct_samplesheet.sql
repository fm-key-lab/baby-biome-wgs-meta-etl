{{ config(materialized='table') }}

with input_data as (
    select
        distinct on(R1, R2, run_name)
        fqs.instrument_platform,
        columns('R[12]'),
        fqs.run_name,
        iso.isolate_id,
        iso.family,
        iso.relationship,
        iso.plate_genus as genus,
        iso.timepoint
    from {{ ref("fct_fastqs") }} as fqs
    left join {{ ref("fct_isolates") }} as iso
           on fqs.isolate_id = iso.isolate_id
),
filtered_input as (
    select *
    from input_data
    where genus is not null
      and family is not null
)
select
    *,
    row_number() over () as "sample" 
from filtered_input