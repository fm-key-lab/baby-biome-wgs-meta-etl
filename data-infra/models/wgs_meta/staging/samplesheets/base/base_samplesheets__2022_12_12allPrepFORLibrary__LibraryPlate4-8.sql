{{ config(materialized='view') }}

select
    null::varchar as family,
    replace(column0, '-', '_') as isolate_id,
    column5 as relationship,
    case
        when column3 is null then column2
        else concat(column2, ' (', column3, ')')
    end as taxon,
    column6 as timepoint
from read_csv({{ source("samplesheets", "LibraryPlate4-8") }})