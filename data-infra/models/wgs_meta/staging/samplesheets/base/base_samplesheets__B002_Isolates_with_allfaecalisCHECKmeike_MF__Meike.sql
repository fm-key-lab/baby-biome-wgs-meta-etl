{{ config(materialized='view') }}

select
    null::varchar as family,
    id as isolate_id,
    "subject" as relationship,
    species || ' ' || spec_notes as taxon,
    timepoint
from read_csv({{ source("samplesheets", "Meike") }})
