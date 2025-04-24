{{ config(materialized='table') }}

with joined as (
  select
      isolates.isolate_id,
      families.family,
      relationships.relationship,
      taxa.plate_taxon,
      taxa.plate_genus,
      timepoints.timepoint,
      timepoints.timepoint_interval
  from {{ ref("stg_samplesheets__isolates") }} as isolates
  join {{ ref("stg_samplesheets__families") }} as families
    on isolates.isolate_id = families.isolate_id
  join {{ ref("stg_samplesheets__relationships") }} as relationships
    on isolates.isolate_id = relationships.isolate_id
  join {{ ref("stg_samplesheets__taxa") }} as taxa
    on isolates.isolate_id = taxa.isolate_id
  join {{ ref("stg_samplesheets__timepoints") }} as timepoints
    on isolates.isolate_id = timepoints.isolate_id
  order by isolates.isolate_id
)
select distinct * from joined