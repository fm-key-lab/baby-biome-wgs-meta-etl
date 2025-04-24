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
    Timepoint as timepoint
from read_csv({{ source("samplesheets", "2024_11_18_Library_prep_plates2") }})