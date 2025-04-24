{{ config(materialized='view') }}

select
    null::varchar as family,
    replace(ID, '-', '_') as isolate_id,
    null::varchar as relationship,
    species as taxon,
    null::varchar as timepoint
from read_csv({{ source("samplesheets", "Sheet1") }})