from pathlib import Path
from fast_excel_duckdb import fast_load_duckdb

downloads = Path.home() / "Downloads"

def load_hj_shipped(columns=None, sheet_name=0, force_rebuild=False):
    xlsx = downloads / "HJ_4W_SHIPPED.xlsx"
    return fast_load_duckdb(
        xlsx,
        sheet_name=sheet_name,
        columns=columns,
        force_rebuild=force_rebuild,
        verbose=True
    )
