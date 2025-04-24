{{ config(materialized='table') }}

with cleaned_taxa as (
    select
        isolate_id,
        case
            -- Bacteroides ovatus/xylanisolvens
            when taxon ilike 'bacteroides%' then 'Bacteroides_ovatus_xylanisolvens'

            -- Bifidobacterium spp
            when (
                taxon ilike 'bifidobacterium%'
                or taxon ilike 'bifidobakterien%'
            ) then 'Bifidobacterium_spp'

            -- Enterococcus faecalis
            when taxon ilike '%enterococcus%' then 'Enterococcus_faecalis'

            -- Escherichia coli
            when (
                taxon ilike 'escherichia%'
                and taxon not ilike 'escherichia%wei%'
                and taxon not ilike 'escherichia%rot%'
            ) then 'Escherichia_coli'

            -- Escherichia coli (red)
            when taxon ilike 'escherichia%rot%' then 'Escherichia_coli_red'

            -- Escherichia coli (white)
            when taxon ilike 'escherichia%wei%' then 'Escherichia_coli_white'

            -- Klebsiella oxytoca
            when taxon ilike 'klebsiella%' then 'Klebsiella_oxytoca'

            -- Lacticaseibacillus casei/paracasei/rhamnosus
            when taxon ilike 'lacticaseibacillus%' then 'Lacticaseibacillus_casei_paracasei_rhamnosus'

            -- Staphylococcus aureus
            when taxon ilike 'staphylococcus%' then 'Staphylococcus_aureus'

            else taxon
        end as plate_taxon
    from {{ ref("stg_samplesheets__isolates") }}
),
resolve_duplicate as (
    -- No conflicting metadata found, so use `any_value()`
    select
        isolate_id,
        any_value(plate_taxon) as plate_taxon
    from cleaned_taxa
    group by isolate_id
)
select
    isolate_id,
    plate_taxon,
    regexp_extract(
        plate_taxon, '^([a-zA-Z]+)_', 1
    ) as plate_genus
from resolve_duplicate