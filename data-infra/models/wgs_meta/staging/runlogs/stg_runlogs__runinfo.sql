{{ config(materialized='table') }}

select
    /*
        Coerces run_type to standardize per EBI controlled vocabulary.

        Because AVITI is not yet allowed, coerces to ILLUMINA.
        See https://www.ebi.ac.uk/ena/portal/api/controlledVocab?field=instrument_platform.
    */
    case    
        when run_type = 'AVITI High output; PE75' then 'ILLUMINA'
        when run_type = 'PE100' then 'ILLUMINA'            
        else null
    end as instrument_platform,

    location_in_backup,
    notes,
    path_to_lab_notebook,
    path_to_pooling_of_pools_sheet,

    /*
        TODO:
        
        Not all wgs runs are provided a run name by SeqCore. Which run name to 
        use when none provided?
        
        Currently, uses the run_name provided by the config, which is added
        in the script that gets the run info. Run names in config are not yet
        the provided run names, even when available.
    */
    coalesce(
        run_name_provided_by_sequencing_center,
        run_name
    ) as run_name,

    -- typos induced by coercing to UTF.
    -- Code complexity is required (`replace(., 'Sr', 'Soer')` would fail).
    array_transform(
        string_split(sent_out_for_by, ' / '),
        x -> regexp_replace(x, 'S.*rensen', 'Soerensen')
    ) as sent_out_for_by,
    
    sequencing_facility
from read_csv({{ source("run_info", "parsed") }})