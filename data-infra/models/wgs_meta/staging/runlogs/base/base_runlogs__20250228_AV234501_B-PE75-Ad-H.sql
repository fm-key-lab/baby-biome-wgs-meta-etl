{{ config(materialized='view') }}

select
    "filename",
    "Barcode 1 (Plate or Row)"      as barcode_1,
    "Barcode 2 (Well or Column)"    as barcode_2,
    "Notes (optional)"              as notes,
    "Library plate name"            as plate,
    "SampleName (optional)"         as sample_name,
    "Library plate well"            as well
from read_csv(
    {{ source("runlogs", "20250228_AV234501_B-PE75-Ad-H") }},
    auto_detect = false,
    columns = {
        'Original sample plate (or first arrayed plate, if source is tubes)'    : varchar,
        'Well'                                                                  : varchar,
        'Library plate name'                                                    : varchar,
        'Library plate well'                                                    : varchar,
        'Barcode 1 (Plate or Row)'                                              : varchar,
        'Barcode 2 (Well or Column)'                                            : varchar,
        'SampleName (optional)'                                                 : varchar,
        'Library prep method (optional)'                                        : varchar,
        'Notes (optional)'                                                      : varchar
    },
    filename = true,
    skip = 13
)