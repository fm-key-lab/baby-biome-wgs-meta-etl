{{ config(materialized='view') }}

select
    replace(a, '-', '_') as isolate_id,
    b as taxon,
    unnest(
        regexp_extract(
            c,
            '^([A-Z])-(\d+M)',
            ['relationship', 'timepoint']
        )
    )
from read_csv({{ source("samplesheets", "Library2mit9M+12M") }})
where a is not null