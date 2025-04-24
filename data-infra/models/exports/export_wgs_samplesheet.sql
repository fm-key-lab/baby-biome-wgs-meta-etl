{{
    config(
        materialized='external',
        location='tools/inputs/samplesheet.csv',
        options={'format': 'csv', 'overwrite': True}
    )
}}

select * from {{ ref("fct_samplesheet") }}