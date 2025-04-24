{{ config(materialized='view') }}

select
    null::varchar as family,
    replace("gDNA from 96-Well", '-', '_') as isolate_id,
    regexp_extract(
        c, '^(\D+)[- ]', 1
    ) as relationship,
    b as taxon,
    regexp_extract(
        c, '[- ](\w+)$', 1
    ) as timepoint
from read_csv({{ source("samplesheets", "LibraryPlate1-3") }})