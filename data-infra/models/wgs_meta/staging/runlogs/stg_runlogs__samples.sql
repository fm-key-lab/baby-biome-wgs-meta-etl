{{ config(materialized='table') }}

with base_runlogs as (
    select * 
    from {{ ref("base_runlogs__230202_SN417_0449_B_HVV3FDRX2") }}
    union all by name
    select *
    from {{ ref("base_runlogs__230922_SN417_0496_A_HJFVCDRX3") }}
    union all by name
    select *
    from {{ ref("base_runlogs__240703_AV234501_B-PE75-Ad-H") }}
    union all by name
    select *
    from {{ ref("base_runlogs__20241105_AV234501_B-PE75-Ad-H") }}
    union all by name
    select *
    from {{ ref("base_runlogs__20250228_AV234501_B-PE75-Ad-H") }}
)
select
    regexp_extract(
        "filename", '^meta/(.*)/log.csv', 1
    ) as run_name,
    columns('barcode_[12]'),
    notes,
    plate,
    sample_name,
    well
from base_runlogs