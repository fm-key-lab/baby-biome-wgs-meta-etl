{{ config(materialized='view') }}

select
    familie as family,
    replace(nummer, '-', '_') as isolate_id,
    mvb as relationship,
    'Escherichia_coli' as taxon,
    try_cast(
        regexp_extract(
            zeitpunkt, '^0:(\d+):00$', 1
        ) as uinteger
    ) || 'M' as timepoint
from read_csv(
    {{ source("samplesheets", "Baby3M_6M_9M") }},
    all_varchar = true,
    normalize_names = true
)
where nummer is not null