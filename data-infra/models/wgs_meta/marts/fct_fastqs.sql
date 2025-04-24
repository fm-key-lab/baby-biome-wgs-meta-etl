{{ config(materialized='table') }}

select
    columns('barcode_[12]'),
    logs.sample_name as fastq_id,
    instrument_platform,
    isolate_id,
    plate,
    columns('R[12]'),
    info.run_name,
    info.notes as run_notes,
    logs.notes as sample_notes,
    well
from {{ ref("stg_weblinks__fastqs") }} as fqs
left join {{ ref("stg_runlogs__tmp") }} as logs
       on fqs.run_name = logs.run_name
      and fqs.sample_name = logs.sample_name
left join {{ ref("stg_runlogs__runinfo") }} as info
       on fqs.run_name = info.run_name