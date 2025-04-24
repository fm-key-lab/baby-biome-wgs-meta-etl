# Data pipeline for WGS data and metadata

## Usage

Clone the repo. Then, from either Raven or Viper clusters:

```bash
module load snakemake
cd <path/to>/baby-biome-wgs-meta-etl
snakemake --config wgs_meta_db=/ptmp/thosi/test-work-dir/wgs/meta/test.duckdb
```