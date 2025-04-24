{{ config(materialized='view') }}

select
    "filename",
    "i5 name" as barcode_1,
    "i7 name" as barcode_2,
    "Notes (optional)" as notes,
    "Original sample plate (or first arrayed plate, if source is tubes)" as plate,
    "SampleName (optional)" as sample_name,
    Well as well
from read_csv(
    {{ source("runlogs", "230202_SN417_0449_B_HVV3FDRX2") }},
    auto_detect = false,
    columns = {
        'Original sample plate (or first arrayed plate, if source is tubes)': varchar,
        'Well': varchar,
        'i5 name': varchar,
        'i7 name': varchar,
        'SampleName (optional)': varchar,
        'Library prep method (optional)': varchar,
        'Notes (optional)': varchar
    },
    filename = true,
    skip = 14
)