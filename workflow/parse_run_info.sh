#!/bin/bash

# DELIM="\t"
DELIM=","

# Add run name
varnames="run_name"
values="${snakemake_wildcards[run_name]}"

# Add notes
notes=$(awk -F, '
BEGIN { OFS = FS; ORS="" }
/^Notes/ { start = 1 }
/^##Sample information/ { start = 0 }
start {
    gsub(/Notes\t+ ?/, "")
    gsub(/,+ ?/, "")
    gsub(/\r ?/, " ")
    print
}
END { if (start) print "" }
' "${snakemake_input[0]}")

varnames+="${DELIM}notes"
values+="$DELIM$notes"

# Add other fields
fields=(
    "Date sent for sequencing" 
    "Sent out for by" 
    "Run type" 
    "Sequencing Facility" 
    "Path to lab notebook (~Nextcloud/keylab)" 
    "Path to pooling of pools sheet (~Nextcloud/keylab)" 
    "Run name provided by sequencing center" 
    "Location in backup"
)

for field in "${fields[@]}"; do
    # 1. For path fields, remove parenthetical "(~/Nextcloud/keylab)"
    # 2. Lowercase
    # 3. Replace spaces with underscores
    varname=$(echo "$field" | sed 's/ (.*//' | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    varnames+="$DELIM$varname"

    # 1. Coerce to utf-8
    # 2. Get row by grep-ing field
    # 3. Return value only
    val=$(iconv -c -f latin1 -t utf-8 "${snakemake_input[0]}" | csvgrep -c 1 -m "$field" | csvcut -c 2 -K 1)
    values+="$DELIM$val"
done

echo -e "$varnames\n$values" &> "${snakemake_output[0]}"