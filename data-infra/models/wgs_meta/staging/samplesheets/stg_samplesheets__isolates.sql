{{ config(materialized='table') }}

with base_samplesheetss as (
    select * 
    from {{ ref("base_samplesheets__2022_12_12allPrepFORLibrary__LibraryPlate1-3") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__2022_12_12allPrepFORLibrary__LibraryPlate4-8") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__20230912_B002_pooled_samples__Sheet1") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__2024_11_07_Library_prep_plates11to37_ENDE__2024_09_19_Library_prep_plates1") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__2024_11_15_allStrainsLibrary2__12M") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__2025_01_10_Library_prep_plates24to36and38to39_setup3__2024_11_18_Library_prep_plates2") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__allStrainsFrozenEcoli2RUN__Baby3M_6M_9M") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__allStrainsFrozenEcoli2RUN__B018_B019_B020_B024_B026_B027_B030_B031_B033_B034_B035") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__B002_Isolates_with_allfaecalisCHECKmeike_MF__Meike") }}
    union all by name
    select *
    from {{ ref("base_samplesheets__ZusammenfassungMaldiB001_alleZeitpunkte__Library2mit9M+12M") }}
)
select
    family,
    isolate_id,
    relationship,
    taxon,
    timepoint
from base_samplesheetss
where isolate_id is not null
  and isolate_id not ilike 'control%'
  and isolate_id != 'empty_well'