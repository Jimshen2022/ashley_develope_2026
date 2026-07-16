from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from pathlib import Path

import pandas as pd


SETUP_SHEET_NAME = "Setup"


def _cell(frame: pd.DataFrame, row_index: int, column_index: int) -> str:
    try:
        value = frame.iat[row_index, column_index]
    except IndexError:
        return ""
    if pd.isna(value):
        return ""
    return str(value).strip()


def _sanitize_quoted_value(value: str) -> str:
    return value.replace("'", "").replace('"', "").strip()


@dataclass(frozen=True)
class VbaSetupParameters:
    workbook_path: Path
    raw_start_date: str
    raw_end_date: str
    as400_user: str
    as400_password: str

    @property
    def clean_start_date(self) -> str:
        return _sanitize_quoted_value(self.raw_start_date)

    @property
    def clean_end_date(self) -> str:
        return _sanitize_quoted_value(self.raw_end_date)

    @property
    def knq_target_date(self) -> str:
        return self.clean_end_date or date.today().strftime("%Y-%m-%d")


def load_vba_setup_parameters(workbook_path: str | Path) -> VbaSetupParameters:
    path = Path(workbook_path)
    setup = pd.read_excel(path, sheet_name=SETUP_SHEET_NAME, engine="pyxlsb", header=None)
    return VbaSetupParameters(
        workbook_path=path,
        raw_start_date=_cell(setup, 1, 2),
        raw_end_date=_cell(setup, 2, 2),
        as400_user=_cell(setup, 0, 17),
        as400_password=_cell(setup, 1, 17),
    )
