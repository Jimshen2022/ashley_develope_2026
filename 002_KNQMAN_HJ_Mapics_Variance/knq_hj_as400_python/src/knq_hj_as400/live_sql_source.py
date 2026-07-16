from __future__ import annotations

from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
from typing import Callable

import pandas as pd

from knq_hj_as400.sql_connectors import OdbcConnector, SqlServerConnector
from knq_hj_as400.vba_setup import VbaSetupParameters, load_vba_setup_parameters
from knq_hj_as400.vba_sql import extract_vba_sql_file


PROJECT_ROOT = Path(__file__).resolve().parents[2]
VBA_DIR = PROJECT_ROOT / "analysis" / "vba"
MANUAL_SHEETS = {
    "exception",
    "KNQ Variances List",
    "Previous_Data",
    "rollback",
}
RAW_DATE_MODULES = {
    "a0042_HJ_4W_Received_SQLADD.bas",
    "a0051_HJ_4W_Shipped_SQLADD.bas",
    "a0_Pull_HJ_SN_RLH_SQLADD.bas",
    "a001_Pull_HJ_SN_O_SQLADD.bas",
}
CLEAN_DATE_MODULES = {
    "a002_KNQ_4W_IMPORTED_SQLSERVER.bas",
    "a003_KNQ_4W_EXPORTED_SQLSERVER.bas",
}


def _ibm_cyymmdd(value: date) -> str:
    return f"1{value:%y%m%d}"


def _escape_sql_text(value: str) -> str:
    return value.replace("'", "''")


def _quote_item_list(items: list[str]) -> str:
    unique_items = []
    seen: set[str] = set()
    for item in items:
        normalized = item.strip()
        if not normalized or normalized == "RP ORDER" or normalized in seen:
            continue
        seen.add(normalized)
        unique_items.append(normalized)
    return ",".join(f"'{_escape_sql_text(item)}'" for item in unique_items)


@dataclass(frozen=True)
class SqlSheetSpec:
    sheet_name: str
    connector_name: str
    module_filename: str | None = None
    query_builder: Callable[["HybridSqlWorkbookSource", list[str] | None], str] | None = None

    def build_query(self, source: "HybridSqlWorkbookSource", item_numbers: list[str] | None = None) -> str:
        if self.query_builder is not None:
            return self.query_builder(source, item_numbers)
        if self.module_filename is None:
            raise ValueError(f"No query source configured for {self.sheet_name}.")
        return extract_vba_sql_file(
            VBA_DIR / self.module_filename,
            substitutions=source.vba_substitutions(self.module_filename),
        )


def _build_item_query(source: "HybridSqlWorkbookSource", item_numbers: list[str] | None = None) -> str:
    item_filter = _quote_item_list(item_numbers or [])
    query = (
        "SELECT t1.STID, T1.ITNBR, T1.ITCLS "
        "FROM AMFLIBA.ITMRVA AS T1 "
        "WHERE T1.STID IN ('335')"
    )
    if item_filter:
        query += f" AND T1.ITNBR in ({item_filter})"
    return query


LIVE_SQL_SHEETS: dict[str, SqlSheetSpec] = {
    "ASYARD": SqlSheetSpec("ASYARD", "hj_sql_server", module_filename="a0_ASYARD_2_SQLADD.bas"),
    "Mapics_OnHand": SqlSheetSpec("Mapics_OnHand", "as400_inventory", module_filename="a0_Mapics_OnHand.bas"),
    "HJ_SN": SqlSheetSpec("HJ_SN", "hj_sql_server", module_filename="a0_Pull_HJ_SN_RLH_SQLADD.bas"),
    "HJ_SN_Orphaned": SqlSheetSpec("HJ_SN_Orphaned", "hj_sql_server", module_filename="a001_Pull_HJ_SN_O_SQLADD.bas"),
    "KNQ_OnHand_Details": SqlSheetSpec(
        "KNQ_OnHand_Details",
        "knq_sql_server",
        module_filename="a0_KNQ_ONHAND_SQLSERVER.bas",
    ),
    "KNQ_4W_Import": SqlSheetSpec(
        "KNQ_4W_Import",
        "knq_sql_server",
        module_filename="a002_KNQ_4W_IMPORTED_SQLSERVER.bas",
    ),
    "KNQ_4W_Export": SqlSheetSpec(
        "KNQ_4W_Export",
        "knq_sql_server",
        module_filename="a003_KNQ_4W_EXPORTED_SQLSERVER.bas",
    ),
    "HJ_4W_Received": SqlSheetSpec(
        "HJ_4W_Received",
        "hj_sql_server",
        module_filename="a0042_HJ_4W_Received_SQLADD.bas",
    ),
    "HJ_4W_Shipped": SqlSheetSpec(
        "HJ_4W_Shipped",
        "hj_sql_server",
        module_filename="a0051_HJ_4W_Shipped_SQLADD.bas",
    ),
    "HJ_2W_SA": SqlSheetSpec(
        "HJ_2W_SA",
        "hj_sql_server",
        module_filename="b031_Mapics_vs_High_Jump_SQLADD.bas",
    ),
    "AS400_SA": SqlSheetSpec(
        "AS400_SA",
        "as400_inventory",
        module_filename="b032_mapics_sa_transaction.bas",
    ),
    "Adjusted": SqlSheetSpec(
        "Adjusted",
        "as400_inventory",
        module_filename="a0_mapics_adjusted.bas",
    ),
    "Item": SqlSheetSpec("Item", "as400_item_master", query_builder=_build_item_query),
}


class HybridSqlWorkbookSource:
    def __init__(
        self,
        workbook_path: str | Path,
        *,
        as_of_date: date | None = None,
    ) -> None:
        self.workbook_path = Path(workbook_path)
        self.setup = load_vba_setup_parameters(self.workbook_path)
        self.as_of_date = as_of_date or date.today()
        self._connectors = {
            "hj_sql_server": SqlServerConnector(server="AshtonWHJSQLprod", database="AAD"),
            "knq_sql_server": SqlServerConnector(server="VPHUVNVPSQ23267", database="ECUS5_KNQ"),
            "as400_inventory": OdbcConnector(
                self._as400_connection_string(catalog_library_list="JIMTDTA")
            ),
            "as400_item_master": OdbcConnector(
                self._as400_connection_string(catalog_library_list="JDETSTDTA")
            ),
        }

    def _as400_connection_string(self, *, catalog_library_list: str) -> str:
        return (
            f"DSN=AFIPROD;UID={self.setup.as400_user};PWD={self.setup.as400_password};"
            f"CatalogLibraryList={catalog_library_list};Persist Security Info=True;"
        )

    def vba_substitutions(self, module_filename: str | None = None) -> dict[str, str]:
        substitutions = {
            "startdate": self.setup.raw_start_date,
            "enddate": self.setup.raw_end_date,
            "targetdatestr": self.setup.knq_target_date,
            "strstart": _ibm_cyymmdd(self.as_of_date - timedelta(days=3)),
            "strend": _ibm_cyymmdd(self.as_of_date),
        }
        if module_filename in CLEAN_DATE_MODULES:
            substitutions["startdate"] = self.setup.clean_start_date
            substitutions["enddate"] = self.setup.clean_end_date
        elif module_filename in RAW_DATE_MODULES:
            substitutions["startdate"] = self.setup.raw_start_date
            substitutions["enddate"] = self.setup.raw_end_date
        return substitutions

    def load_manual_sheet(self, sheet_name: str) -> pd.DataFrame:
        return pd.read_excel(self.workbook_path, sheet_name=sheet_name, engine="pyxlsb")

    def fetch_sql_sheet(self, sheet_name: str, *, item_numbers: list[str] | None = None) -> pd.DataFrame:
        spec = LIVE_SQL_SHEETS[sheet_name]
        connector = self._connectors[spec.connector_name]
        query = spec.build_query(self, item_numbers=item_numbers)
        return connector.read_sql(query)

    def fetch_knq_onhand_summary(self) -> pd.DataFrame:
        details = self.fetch_sql_sheet("KNQ_OnHand_Details")
        frame = details.copy()
        frame.columns = [str(column) for column in frame.columns]
        item_col = "M? h¨¤ng"
        import_col = "L??ng nh?p"
        export_col = "L??ng xu?t"
        balance_col = "SL T?n"
        grouped = (
            frame.assign(
                **{
                    item_col: frame[item_col].fillna("").astype(str).str.strip(),
                    import_col: pd.to_numeric(frame[import_col], errors="coerce").fillna(0),
                    export_col: pd.to_numeric(frame[export_col], errors="coerce").fillna(0),
                    balance_col: pd.to_numeric(frame[balance_col], errors="coerce").fillna(0),
                }
            )
            .groupby(item_col, dropna=False)[[import_col, export_col, balance_col]]
            .sum()
            .reset_index()
        )
        grouped.columns = ["Item", "ImportedQty", "ExportedQty", "KNQ_ONHAND"]
        return grouped

    def derive_hj_ng(self, hj_sn: pd.DataFrame) -> pd.DataFrame:
        frame = hj_sn.copy()
        frame["location_id"] = frame["location_id"].fillna("").astype(str)
        mask = frame["location_id"].str.startswith("NG") & (frame["location_id"] != "NG001SC3")
        columns = ["wh_id", "serial_number", "item_number", "location_id", "received_date"]
        return frame.loc[mask, columns].reset_index(drop=True)

    def load_required_base_sheets(self) -> dict[str, pd.DataFrame]:
        base_sheet_names = [
            "ASYARD",
            "Mapics_OnHand",
            "HJ_SN",
            "HJ_SN_Orphaned",
            "KNQ_4W_Import",
            "KNQ_4W_Export",
            "HJ_4W_Received",
            "HJ_4W_Shipped",
            "HJ_2W_SA",
            "AS400_SA",
            "Adjusted",
        ]
        sheets = {sheet_name: self.fetch_sql_sheet(sheet_name) for sheet_name in base_sheet_names}
        sheets["KNQ_OnHand"] = self.fetch_knq_onhand_summary()
        sheets["HJ_NG"] = self.derive_hj_ng(sheets["HJ_SN"])
        for manual_sheet in MANUAL_SHEETS:
            sheets[manual_sheet] = self.load_manual_sheet(manual_sheet)
        return sheets
