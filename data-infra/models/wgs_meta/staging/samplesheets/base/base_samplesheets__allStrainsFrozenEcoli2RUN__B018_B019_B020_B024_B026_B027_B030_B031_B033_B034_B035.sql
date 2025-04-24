{{ config(materialized='view') }}

select
    familie as family,
    case
        when starts_with(nummer, 'B') then replace(nummer, '-', '_')
        else concat(familie, '_', nummer) 
    end as isolate_id,
    mvb as relationship,
    'Escherichia_coli' as taxon,
    zeitpunkt as timepoint
from read_csv(
    {{ source("samplesheets", "B018_B019_B020_B024_B026_B027_B030_B031_B033_B034_B035") }},
    normalize_names = true,
    union_by_name = true
)
where nummer is not null