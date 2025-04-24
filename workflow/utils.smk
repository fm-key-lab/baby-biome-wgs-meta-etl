from collections.abc import Callable, Iterable
from functools import partial
from pathlib import Path

DBT_PROFILE         = 'profiles.yml'
FASTQS              = 'meta/{run_name}/fastqs.txt'
RUN_INFO            = 'meta/{run_name}/info.csv'
RUN_LOG             = 'meta/{run_name}/log.csv'
SAMPLESHEET         = 'meta/samplesheets/{samplesheet}.xlsx'
SAMPLESHEET_SHEET   = 'meta/samplesheets/{samplesheet}.{sheet}.csv'
WGS_INPUTS          = 'tools/inputs_tmp.csv' # NOTE: Partitioned writes throw an error if directory is not named *.csv


def lookup_data(dpath: str, dname: str, dconfig: dict[str, str] = None) -> str | dict[str, str]:
    """Retrieve metadata for data.

    For data configured as a list of data file records with a unique "name"
    field, finds the record matching "dname" and returns "dpath" from the record.
    """
    matchdat = lambda __: __ == dname
    metadata = next(filter(lambda dat: matchdat(dat['name']), dconfig))
    returned = lookup(dpath=dpath, within=metadata)
    return returned


lookup_wgs_run: Callable[[str, str], str | dict[str, str]] = \
    partial(lookup_data, dconfig=lookup(dpath='/wgs/runs', within=config))


lookup_wgs_samplesheet: Callable[[str, str], str | dict[str, str]] = \
    partial(lookup_data, dconfig=lookup(dpath='/wgs/samplesheets', within=config))


def collect_samplesheets() -> list[str]:
    """Collect from WGS samplesheets respective xlsx sheets."""
    render_path = lambda **kw: SAMPLESHEET_SHEET.format(**kw)
    samplesheet_names = list(map(lambda run: run['name'], config['wgs']['samplesheets']))
    paths = [
        render_path(samplesheet=i, sheet=j)
        for i in samplesheet_names
        for j in lookup_wgs_samplesheet('/sheets', i)
    ]
    return paths


def collect_from_runs(target: str | list[str]) -> str | Iterable[str]:
    """Collect `target` from all WGS runs."""
    wgs_runs = list(map(lambda run: run['name'], config['wgs']['runs']))
    wgs_targets = expand(target, run_name=wgs_runs)
    return wgs_targets