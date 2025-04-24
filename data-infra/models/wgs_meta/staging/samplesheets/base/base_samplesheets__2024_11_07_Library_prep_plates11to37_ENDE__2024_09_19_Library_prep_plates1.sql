{{ config(materialized='view') }}

select
    Family as family,
    replace(ID, '-', '_') as isolate_id,
    "Subject" as relationship,
    'Escherichia_coli' as taxon,
    Timepoint as timepoint
from read_csv({{ source("samplesheets", "2024_09_19_Library_prep_plates1") }})