{{
    config(
        materialized='external',
        location='tools/inputs_tmp.csv',
        options={
            'file_extension': 'csv',
            'format': 'csv',
            'overwrite': True,
            'partition_by': 'genus, family, run_name'
        }
    )
}}

-- NOTE: Partitioned writes throw an error if config location is not *.csv

select * from {{ ref("fct_samplesheet") }}