{{ config(materialized='table') }}

with stg_runlogs as (
    select * from {{ ref("stg_runlogs__samples") }}
),
cleaned_sample_names as (
    select
        * exclude (sample_name),
        -- SeqCore FASTQ paths always (?) use '-' for sample names, not '_'
        regexp_replace(
            -- Trim whitespace
            rtrim(
                sample_name
            ), '_', '-', 'g'
        ) as sample_name
    from stg_runlogs
),
-- TODO: Clarify meanings of fields: fastq_id, isolate_id, and sample_name.
--       For "index-shifted" samples,  
-- Use '_' in isolate_ids
parsed_isolate_ids as (
    select
        *,
        case
            /*
                Addresses known index swapping across wells in 230119_B001_Lib
                library plate. Correct sample names are provided in the run log
                notes.
            */
            when notes like '%fastqID%' then regexp_extract(
                notes, 'fastqID_of_sample:(plate\d+_[A-L]\d+|(B\d+)_\d+)$', 1
            )

            -- Sample wells
            when sample_name ^@ 'B' or sample_name ^@ 'P' then regexp_replace(sample_name, '-', '_')

            -- Non-sample wells, eg controls
            when sample_name ilike 'control%'
                or sample_name ^@ 'plate'
                or sample_name ^@ 'ctr'
                or sample_name similar to '\d+-[glp]w'
            then null
            else null
        end as isolate_id
    from cleaned_sample_names
),
/*
    extract plate numbers from plate field with patterns
        - ^Library Plate (\d+)$'
        - ^Library Platte(\d+)$
        - ^P(\d+)$
        - ^Platte_(\d+)$
*/
parsed_plates as (
    select
        * exclude (plate),
        cast(
            regexp_extract(
                plate,
                '^.*[P|e| |_](\d+)$',
                1
            )
            as usmallint
        ) as plate
    from parsed_isolate_ids
)
select * from parsed_plates