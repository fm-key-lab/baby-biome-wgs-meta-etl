# Data pipeline for WGS data and metadata

## Usage

Clone the repo. Then, from either Raven or Viper clusters:

```bash
module load snakemake
THIS_PROJ=<path/to>/baby-biome-wgs-meta-etl
cd $THIS_PROJ
snakemake --config wgs_meta_db=<path/to>/wgs-meta.duckdb wgs_meta_dir=$THIS_PROJ/data-infra
```