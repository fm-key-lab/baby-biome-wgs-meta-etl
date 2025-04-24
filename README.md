# Data pipeline for WGS data and metadata

## Usage

Clone the repo. Then, from either Raven or Viper clusters:

```bash
module load snakemake
THIS_PROJ=<path/to>/baby-biome-wgs-meta-etl
cd $THIS_PROJ
snakemake --config wgs_meta_db=<path/to>/wgs-meta.duckdb wgs_meta_dir=$THIS_PROJ/data-infra
```

Several choices in the Snakefile allow it to be used as a module within other Snakemake pipelines (e.g., extensive use of `workflow.source_path` and not using `workflow.basedir` in the `dbt` rules)
