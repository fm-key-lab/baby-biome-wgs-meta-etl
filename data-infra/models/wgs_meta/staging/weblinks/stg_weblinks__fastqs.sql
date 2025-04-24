{{ config(materialized='table') }}

with fastq_files as (
    select
        column0 as "file",
        regexp_extract(
            "filename",
            '^meta/(.*)/fastqs.txt$',
            1
        ) as run_name
    from read_csv(
        {{ source("fastqs", "weblinks") }},
        delim = '\t',
        filename = true,
        header = false
    )
    where not ends_with("file", '.md5')
),
parsed_filenames as (
    select
        run_name,
        parse_filename("file") as file_basename,
        /*
            Extract sample info from FASTQ filename.

            Note that
                - regexp_extract with LIST requires a constant pattern
                - ordering of cases matters, since 230119_B001_Lib pattern 
                will match 230913_B002_B001_Lib
        */
        case
            -- 20250228_AV234501_250228-086-B-PE75-FS-HO
            when "file" similar to '.*mpimg_L\d+_Mbiome-Pool-v2-.*' then regexp_extract(
                "file",
                'mpimg_L\d+_Mbiome-Pool-v2-([1-2]\d+-[a-z]w|ctr-P\d+-[A-H]\d+|B\d+-\d+)_R(1|2).fastq.gz$',
                ['sample_name', 'read_pair']
            )
            -- 20241105_AV234501_B-PE75-Ad-HiO
            when "file" similar to '.*mpimg_L\d+_Fenk-Pool-.*' then regexp_extract(
                "file",
                'mpimg_L\d+_Fenk-Pool-(control|B\d+-\d+)_R(1|2).fastq.gz$',
                ['sample_name', 'read_pair']
            )
            -- 230913_B002_B001_Lib
            when "file" similar to '.*mpimg_L\d+-\d_Poolall_.*' then regexp_extract(
                "file",
                'mpimg_L\d+-\d_Poolall_(Control\d+-\d+|[BP]\d+-\d+)_S\d+_R(1|2)_001.fastq.gz$',
                ['sample_name', 'read_pair']
            )
            -- 240704_B002_B001_Lib_AVITI_reseq
            when "file" similar to '.*mpg_L\d+_B\d+-\d+-.*' then regexp_extract(
                "file",
                'mpg_L\d+_B\d+-\d+-(Control\d+-\d+|[BP]\d+-\d+)_R(1|2).fastq.gz$',
                ['sample_name', 'read_pair']
            )
            -- 230119_B001_Lib
            when "file" similar to '.*mpimg_L\d+-\d_.*' then regexp_extract(
                "file",
                'mpimg_L\d+-\d_(plate\d+-[A-L]\d+|B\d+-\d+)_S\d+_R(1|2)_001.fastq.gz$',
                ['sample_name', 'read_pair']
            )
            else null
        end
        as extracted
    from fastq_files
),
fastqs_annot as (
    select
        run_name,
        file_basename,
        extracted.* exclude (read_pair),
        'R' || extracted.read_pair as read_pair
    from parsed_filenames
),
-- Match read pairs for paired-end FASTQs files
fastqs_pe as (
    select
        run_name,
        sample_name,
        unnest(R2) as R2,
        unnest(R1) as R1
    from (
        select
            /*
                In some cases, a sample has been sequenced more than once within
                a run (e.g., "B001-4186"). The following code allows for multiple
                pairs of data files to be associated with a single 
                (run_name, sample_name).
            */
            list_distinct(
                array_agg(
                    case when read_pair = 'R1' then file_basename end
                )
            ) as R1,
            list_distinct(
                array_agg(
                    case when read_pair = 'R2' then file_basename end
                )
            ) as R2,
            run_name,
            sample_name
        from fastqs_annot
        group by run_name, sample_name
    )
),
filtered_samples as (
    select *
    from fastqs_pe
    -- Removes samples not in run log (e.g., '\d+-[glp]w' samples)
    where sample_name not similar to '^\d+-[glp]w$'
)
select * from filtered_samples