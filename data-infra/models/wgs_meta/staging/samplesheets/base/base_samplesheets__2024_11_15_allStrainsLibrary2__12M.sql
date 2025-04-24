{{ config(materialized='view') }}

select
    /*
        Addresses error in family field.
        Isolate ID prefix is authoritative here.
    */
    -- Family as family,
    regexp_extract(ID, '^(B\d+)-\d+$', 1) as family,
    replace(ID, '-', '_') as isolate_id,
    "Subject" as relationship,
    'Escherichia_coli' as taxon,
    '12M' as timepoint
from read_csv(
    {{ source("samplesheets", "12M") }},
    all_varchar = true
)
where ID is not null