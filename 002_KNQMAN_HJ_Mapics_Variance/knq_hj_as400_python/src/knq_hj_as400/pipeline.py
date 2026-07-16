from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
from typing import Iterable

import pandas as pd


FINAL_COLUMNS = [
    "Whse",
    "Item Number",
    "Mapics HJ Diff",
    "Mapics",
    "Shipped Not Invoiced",
    "YA DOOR Qty",
    "WA",
    "YA Qty",
    "YA Received",
    "YA Qty Remained",
    "Exception",
    "KNQMAN Qty",
    "KNQ HJ Variance",
    "ABS",
    "PO",
    "Trip",
    "Mapics Adjusted",
    "NG",
    "KNQ delared but HJ not",
    "Trailer in Yard KNQ not",
    "GAP",
    "KNQ-AS400",
    "EX001AA1",
    "SH001AA1",
    "SH001AA2",
    "EX001AA2",
    "RollBack",
    "KNQMAN vs HJ Checked detail",
    "Root Cause",
    "Solution",
    "Owner",
    "Due Date",
    "Status",
    "VarianceQty",
    "Category",
    "ABS(Variances)",
    "Variance",
    "Gap",
    "Orphaned",
    "Orphaned.1",
    "Scrap",
    "Gap.1",
    "Product_category",
]

REQUIRED_SHEETS = [
    "Summary",
    "DATA",
    "KNQ_OnHand",
    "HJ_SN",
    "Mapics_OnHand",
    "ASYARD",
    "HJ_2W_SA",
    "AS400_SA",
    "KNQ_4W_Import",
    "KNQ_4W_Export",
    "HJ_4W_Received",
    "HJ_4W_Shipped",
    "Adjusted",
    "HJ_NG",
    "exception",
    "KNQ Variances List",
    "Previous_Data",
    "rollback",
    "Item",
    "HJ_SN_Orphaned",
]


@dataclass
class WorkbookSnapshot:
    workbook_path: Path
    sheets: dict[str, pd.DataFrame]
    as_of_date: date


def _clean_text(series: pd.Series) -> pd.Series:
    return series.fillna("").astype(str).str.strip()


def _to_number(series: pd.Series) -> pd.Series:
    return pd.to_numeric(series, errors="coerce").fillna(0)


def _to_excel_date(series: pd.Series) -> pd.Series:
    numeric = pd.to_numeric(series, errors="coerce")
    converted = pd.to_datetime(numeric, unit="D", origin="1899-12-30", errors="coerce")
    fallback = pd.to_datetime(series, errors="coerce")
    return converted.fillna(fallback)


def _series_lookup(items: pd.Series, values: pd.Series) -> pd.Series:
    mapping = values.to_dict()
    return items.map(mapping).fillna(0)


def _infer_as_of_date(summary_df: pd.DataFrame) -> date:
    pattern = re.compile(r"(\d{4})/(\d{2})/(\d{2})")
    for value in summary_df.fillna("").astype(str).to_numpy().ravel():
        match = pattern.search(value)
        if match:
            return date(int(match.group(1)), int(match.group(2)), int(match.group(3)))
    return date.today()


def load_snapshot(workbook_path: str | Path) -> WorkbookSnapshot:
    path = Path(workbook_path)
    sheets = {
        sheet_name: pd.read_excel(path, sheet_name=sheet_name, engine="pyxlsb")
        for sheet_name in REQUIRED_SHEETS
    }
    return WorkbookSnapshot(
        workbook_path=path,
        sheets=sheets,
        as_of_date=_infer_as_of_date(sheets["Summary"]),
    )


def _build_item_class_map(item_df: pd.DataFrame) -> pd.Series:
    if item_df.empty or item_df.shape[1] < 3:
        return pd.Series(dtype="object")
    frame = item_df.iloc[:, :3].copy()
    frame.columns = ["STID", "ITNBR", "ITCLS"]
    frame["ITNBR"] = _clean_text(frame["ITNBR"])
    frame["ITCLS"] = _clean_text(frame["ITCLS"])
    frame = frame[frame["ITNBR"] != ""].drop_duplicates(subset=["ITNBR"], keep="last")
    return frame.set_index("ITNBR")["ITCLS"]


def _derive_product_category(item_number: str, item_class: str) -> str:
    if not item_class:
        return "Check"
    if not item_class.startswith("Z"):
        return "RP"
    if item_number[:1] in {"A", "B", "D", "Q", "R", "E", "H", "T", "W", "Z"}:
        return "CG"
    return "UPH"


def _mark_as400_status(hj_2w_sa: pd.DataFrame, as400_sa: pd.DataFrame) -> pd.DataFrame:
    frame = hj_2w_sa.copy()
    frame["item_number"] = _clean_text(frame["item_number"])
    frame["c_number"] = _clean_text(frame["c_number"])
    frame["qty"] = _to_number(frame["qty"])

    as_frame = as400_sa.copy()
    as_frame["ITNBR"] = _clean_text(as_frame["ITNBR"])
    as_frame["ORDNO"] = _clean_text(as_frame["ORDNO"])
    as_frame["REFNO"] = _clean_text(as_frame["REFNO"])
    as_frame["Qty"] = _to_number(as_frame["Qty"])
    as_frame["refno7"] = as_frame["REFNO"].str[-7:]

    dict_as = as_frame.groupby(["ITNBR", "ORDNO"])["Qty"].sum().to_dict()
    refno_set = {value for value in as_frame["refno7"] if value}
    dict_hj = (
        frame[frame["item_number"] != "RP ORDER"]
        .groupby(["item_number", "c_number"])["qty"]
        .sum()
        .to_dict()
    )

    def compute_status(row: pd.Series) -> str:
        item_number = row["item_number"]
        c_number = row["c_number"]
        if item_number == "RP ORDER":
            return "AS400_SA_DONE" if c_number in refno_set else "AS400_STILL_NO_SA"
        key = (item_number, c_number)
        if key not in dict_as:
            return "AS400_STILL_NO_SA"
        return "AS400_SA_DONE" if dict_hj.get(key, 0) <= dict_as[key] else "AS400_STILL_NO_SA"

    frame["AS400_SA_Status"] = frame.apply(compute_status, axis=1)
    return frame


def _build_shipped_not_invoiced(hj_2w_sa: pd.DataFrame, as400_sa: pd.DataFrame) -> pd.Series:
    unresolved = _mark_as400_status(hj_2w_sa, as400_sa)
    unresolved = unresolved[unresolved["AS400_SA_Status"] == "AS400_STILL_NO_SA"].copy()

    normal = unresolved[unresolved["item_number"] != "RP ORDER"]
    normal_qty = normal.groupby("item_number")["qty"].sum()

    rp_c_numbers = set(_clean_text(unresolved.loc[unresolved["item_number"] == "RP ORDER", "c_number"]))
    as_frame = as400_sa.copy()
    as_frame["ITNBR"] = _clean_text(as_frame["ITNBR"])
    as_frame["REFNO"] = _clean_text(as_frame["REFNO"])
    as_frame["Qty"] = _to_number(as_frame["Qty"])
    as_frame["refno7"] = as_frame["REFNO"].str[-7:]
    rp_qty = as_frame[as_frame["refno7"].isin(rp_c_numbers)].groupby("ITNBR")["Qty"].sum()

    combined = normal_qty.add(rp_qty, fill_value=0)
    combined.index = combined.index.astype(str)
    return combined


def _build_po_exception_qty(knq_import: pd.DataFrame, hj_received: pd.DataFrame, as_of_date: date) -> pd.Series:
    knq_po = set(_clean_text(knq_import.iloc[:, 5]))
    frame = hj_received.copy()
    frame["Date"] = _to_excel_date(frame["Date"])
    frame["PO#"] = _clean_text(frame["PO#"])
    frame["Item#"] = _clean_text(frame["Item#"])
    frame["Received_Qty"] = _to_number(frame["Received_Qty"])
    delta = (pd.Timestamp(as_of_date) - frame["Date"]).dt.days
    mask = delta.between(0, 14) & ~frame["PO#"].isin(knq_po)
    return frame.loc[mask].groupby("Item#")["Received_Qty"].sum()


def _build_trip_exception_qty(knq_export: pd.DataFrame, hj_shipped: pd.DataFrame, as_of_date: date) -> pd.Series:
    known_trips = set(_clean_text(knq_export.iloc[:, 7]))
    frame = hj_shipped.copy()
    frame["Date"] = _to_excel_date(frame["Date"])
    frame["Trip_Number"] = _clean_text(frame["Trip_Number"])
    frame["Item#"] = _clean_text(frame["Item#"])
    frame["Shipped_Qty"] = _to_number(frame["Shipped_Qty"])
    delta = (pd.Timestamp(as_of_date) - frame["Date"]).dt.days
    mask = delta.between(0, 14) & ~frame["Trip_Number"].isin(known_trips)
    return frame.loc[mask].groupby("Item#")["Shipped_Qty"].sum()


def _build_knq_declared_not_hj(knq_import: pd.DataFrame, hj_received: pd.DataFrame, as_of_date: date) -> pd.Series:
    received_pos = set(_clean_text(hj_received["PO#"]))
    frame = knq_import.copy()
    frame["knq_po"] = _clean_text(frame.iloc[:, 5])
    frame["item"] = _clean_text(frame.iloc[:, 10])
    frame["qty"] = _to_number(frame.iloc[:, 13])
    frame["date"] = _to_excel_date(frame.iloc[:, 9])
    delta = (pd.Timestamp(as_of_date) - frame["date"]).dt.days
    mask = delta.between(0, 14) & ~frame["knq_po"].isin(received_pos)
    return frame.loc[mask].groupby("item")["qty"].sum()


def _build_trailer_in_yard_not_knq(asyard: pd.DataFrame, knq_import: pd.DataFrame) -> pd.Series:
    knq_pos = set(_clean_text(knq_import.iloc[:, 5]))
    frame = asyard.copy()
    frame["customer_po_number"] = _clean_text(frame["customer_po_number"])
    frame["item_number"] = _clean_text(frame["item_number"])
    frame["Qty_shipped"] = _to_number(frame["Qty_shipped"])
    mask = ~frame["customer_po_number"].isin(knq_pos)
    return frame.loc[mask].groupby("item_number")["Qty_shipped"].sum()


def _count_hj_location(hj_sn: pd.DataFrame, location: str) -> pd.Series:
    frame = hj_sn.copy()
    frame["item_number"] = _clean_text(frame["item_number"])
    frame["location_id"] = _clean_text(frame["location_id"])
    return frame.loc[frame["location_id"] == location].groupby("item_number").size()


def _build_orphaned_counts(hj_sn_orphaned: pd.DataFrame) -> pd.Series:
    frame = hj_sn_orphaned.copy()
    frame["item_number"] = _clean_text(frame["item_number"])
    frame["location_id"] = _clean_text(frame["location_id"])
    mask = ~frame["location_id"].str.startswith("NG001OP", na=False)
    return frame.loc[mask].groupby("item_number").size()


def _prepare_previous_annotations(previous_data: pd.DataFrame) -> pd.DataFrame:
    wanted = [
        "Item Number",
        "KNQMAN vs HJ Checked detail",
        "Root Cause",
        "Solution",
        "Owner",
        "Due Date",
        "Status",
    ]
    frame = previous_data.loc[:, [column for column in wanted if column in previous_data.columns]].copy()
    frame["Item Number"] = _clean_text(frame["Item Number"])
    return frame.drop_duplicates(subset=["Item Number"], keep="first")


def _apply_previous_annotations(data: pd.DataFrame, previous_data: pd.DataFrame) -> pd.DataFrame:
    annotations = _prepare_previous_annotations(previous_data)
    merged = data.merge(annotations, on="Item Number", how="left")
    for column in [
        "KNQMAN vs HJ Checked detail",
        "Root Cause",
        "Solution",
        "Owner",
        "Due Date",
        "Status",
    ]:
        merged[column] = merged[column].fillna("")
    return merged


def _apply_no_variance_defaults(data: pd.DataFrame, as_of_date: date) -> pd.DataFrame:
    frame = data.copy()
    base_mask = (frame["Mapics HJ Diff"] == 0) & (frame["GAP"] == 0)

    po_mask = base_mask & (frame["PO"] > 0) & (frame["Trip"] == 0)
    frame.loc[po_mask, "KNQMAN vs HJ Checked detail"] = "POs are still not updated to KNQ"
    frame.loc[po_mask, "Root Cause"] = "KNQ update time variance"
    frame.loc[po_mask, "Solution"] = "no need action"
    frame.loc[po_mask, "Owner"] = "Rita"
    frame.loc[po_mask, "Due Date"] = pd.Timestamp(as_of_date + timedelta(days=2))
    frame.loc[po_mask, "Status"] = "Closed"

    trip_mask = base_mask & (frame["PO"] == 0) & (frame["Trip"] > 0)
    frame.loc[trip_mask, "KNQMAN vs HJ Checked detail"] = "Trip shipped but still not be updated to KNQ"
    frame.loc[trip_mask, "Root Cause"] = "KNQ update time variance"
    frame.loc[trip_mask, "Solution"] = "no need action"
    frame.loc[trip_mask, "Owner"] = "Rita"
    frame.loc[trip_mask, "Due Date"] = pd.Timestamp(as_of_date)
    frame.loc[trip_mask, "Status"] = "Closed"

    no_variance_mask = base_mask & (frame["Mapics"] == frame["WA"]) & (frame["WA"] == frame["KNQMAN Qty"])
    frame.loc[no_variance_mask, "KNQMAN vs HJ Checked detail"] = "No Variance"
    frame.loc[no_variance_mask, "Root Cause"] = "No Variance"
    frame.loc[no_variance_mask, "Solution"] = "no need action"
    frame.loc[no_variance_mask, "Owner"] = "All"
    frame.loc[no_variance_mask, "Due Date"] = pd.Timestamp(as_of_date)
    frame.loc[no_variance_mask, "Status"] = "Closed"

    return frame


def build_data_report(workbook_path: str | Path) -> pd.DataFrame:
    snapshot = load_snapshot(workbook_path)
    sheets = snapshot.sheets

    hj_sn = sheets["HJ_SN"].copy()
    hj_sn["item_number"] = _clean_text(hj_sn["item_number"])
    hj_sn["location_id"] = _clean_text(hj_sn["location_id"])

    mapics = sheets["Mapics_OnHand"].copy()
    mapics["ITNBR"] = _clean_text(mapics["ITNBR"])
    mapics["MOHTQ"] = _to_number(mapics["MOHTQ"])

    knq_onhand = sheets["KNQ_OnHand"].copy()
    knq_onhand["Item"] = _clean_text(knq_onhand["Item"])
    knq_onhand["KNQ_ONHAND"] = _to_number(knq_onhand["KNQ_ONHAND"])

    yard = sheets["ASYARD"].copy()
    yard["item_number"] = _clean_text(yard["item_number"])
    yard["location_name"] = _clean_text(yard["location_name"])
    yard["Qty_shipped"] = _to_number(yard["Qty_shipped"])
    yard["Qty_received"] = _to_number(yard["Qty_received"])
    yard["Qty_remaining"] = _to_number(yard["Qty_remaining"])

    item_universe = sorted(
        set(mapics["ITNBR"])
        | set(knq_onhand["Item"])
        | set(hj_sn.loc[hj_sn["location_id"] != "SH001AA2", "item_number"])
    )
    data = pd.DataFrame({"Item Number": item_universe})
    data["Whse"] = "335"

    mapics_qty = mapics.groupby("ITNBR")["MOHTQ"].sum()
    wa_qty = hj_sn.loc[hj_sn["location_id"] != "SH001AA2"].groupby("item_number").size()
    knq_qty = knq_onhand.groupby("Item")["KNQ_ONHAND"].sum()
    ya_qty = yard.groupby("item_number")["Qty_shipped"].sum()
    ya_received = yard.groupby("item_number")["Qty_received"].sum()
    ya_remaining = yard.groupby("item_number")["Qty_remaining"].sum()
    ya_door = yard.loc[yard["location_name"].str.startswith("D", na=False)].groupby("item_number")["Qty_shipped"].sum()
    shipped_not_invoiced = _build_shipped_not_invoiced(sheets["HJ_2W_SA"], sheets["AS400_SA"])

    data["Mapics"] = _series_lookup(data["Item Number"], mapics_qty)
    data["WA"] = _series_lookup(data["Item Number"], wa_qty)
    data["KNQMAN Qty"] = _series_lookup(data["Item Number"], knq_qty)
    data["YA Qty"] = _series_lookup(data["Item Number"], ya_qty)
    data["YA Received"] = _series_lookup(data["Item Number"], ya_received)
    data["YA Qty Remained"] = _series_lookup(data["Item Number"], ya_remaining)
    data["YA DOOR Qty"] = _series_lookup(data["Item Number"], ya_door)
    data["Shipped Not Invoiced"] = _series_lookup(data["Item Number"], shipped_not_invoiced)
    data["Mapics HJ Diff"] = data["WA"] + data["YA DOOR Qty"] + data["Shipped Not Invoiced"] - data["Mapics"]
    data["KNQ HJ Variance"] = data["WA"] + data["YA Qty"] + data["Shipped Not Invoiced"] - data["KNQMAN Qty"]
    data["ABS"] = data["KNQ HJ Variance"].abs()

    data["PO"] = _series_lookup(
        data["Item Number"],
        _build_po_exception_qty(sheets["KNQ_4W_Import"], sheets["HJ_4W_Received"], snapshot.as_of_date),
    )
    data["Trip"] = _series_lookup(
        data["Item Number"],
        _build_trip_exception_qty(sheets["KNQ_4W_Export"], sheets["HJ_4W_Shipped"], snapshot.as_of_date),
    )
    data["Mapics Adjusted"] = _series_lookup(
        data["Item Number"],
        sheets["Adjusted"].assign(ITNBR=_clean_text(sheets["Adjusted"]["ITNBR"]), Qty=_to_number(sheets["Adjusted"]["Qty"]))
        .groupby("ITNBR")["Qty"]
        .sum(),
    )
    data["NG"] = _series_lookup(
        data["Item Number"],
        sheets["HJ_NG"].assign(item_number=_clean_text(sheets["HJ_NG"]["item_number"]))
        .groupby("item_number")
        .size(),
    )
    data["KNQ delared but HJ not"] = _series_lookup(
        data["Item Number"],
        _build_knq_declared_not_hj(sheets["KNQ_4W_Import"], sheets["HJ_4W_Received"], snapshot.as_of_date),
    )
    data["Trailer in Yard KNQ not"] = _series_lookup(
        data["Item Number"],
        _build_trailer_in_yard_not_knq(sheets["ASYARD"], sheets["KNQ_4W_Import"]),
    )
    data["GAP"] = data["KNQMAN Qty"] + data["PO"] - data["Trip"] - data["KNQ delared but HJ not"] - data["WA"]
    data["KNQ-AS400"] = data["KNQMAN Qty"] - data["Mapics"]
    data["EX001AA1"] = _series_lookup(data["Item Number"], _count_hj_location(hj_sn, "EX001AA1"))
    data["SH001AA1"] = _series_lookup(data["Item Number"], _count_hj_location(hj_sn, "SH001AA1"))
    data["SH001AA2"] = _series_lookup(data["Item Number"], _count_hj_location(hj_sn, "SH001AA2"))
    data["EX001AA2"] = _series_lookup(data["Item Number"], _count_hj_location(hj_sn, "EX001AA2"))
    data["RollBack"] = _series_lookup(
        data["Item Number"],
        sheets["rollback"].assign(ITNBR=_clean_text(sheets["rollback"]["ITNBR"]), TRQTY=_to_number(sheets["rollback"]["TRQTY"]))
        .groupby("ITNBR")["TRQTY"]
        .sum(),
    )
    data["Exception"] = _series_lookup(
        data["Item Number"],
        sheets["exception"].assign(Item=_clean_text(sheets["exception"]["Item"]), Qty=_to_number(sheets["exception"]["Qty"]))
        .groupby("Item")["Qty"]
        .sum(),
    )

    data = _apply_previous_annotations(data, sheets["Previous_Data"])
    data["VarianceQty"] = -data["GAP"]
    data["Category"] = data["VarianceQty"].map(
        lambda value: "No_Variance" if value == 0 else ("KNQ Qty > HJ Qty" if value < 0 else "KNQ Qty < HJ Qty")
    )
    data["ABS(Variances)"] = data["VarianceQty"].abs()
    data["Variance"] = _series_lookup(
        data["Item Number"],
        sheets["KNQ Variances List"]
        .assign(
            **{
                "Item Number": _clean_text(sheets["KNQ Variances List"]["Item Number"]),
                "ABS(Qty)": _to_number(sheets["KNQ Variances List"]["ABS(Qty)"]),
            }
        )
        .groupby("Item Number")["ABS(Qty)"]
        .sum(),
    )
    data["Gap"] = data["Variance"] - data["ABS(Variances)"]
    data["Orphaned"] = ""
    data["Orphaned.1"] = _series_lookup(data["Item Number"], _build_orphaned_counts(sheets["HJ_SN_Orphaned"]))
    data["Scrap"] = ""
    data["Gap.1"] = ""

    item_class_map = _build_item_class_map(sheets["Item"])
    data["Product_category"] = data["Item Number"].map(
        lambda item: _derive_product_category(item, item_class_map.get(item, ""))
    )
    data = _apply_no_variance_defaults(data, snapshot.as_of_date)

    ordered = data.loc[:, FINAL_COLUMNS].copy()
    numeric_columns = [
        column
        for column in ordered.columns
        if column
        not in {
            "Whse",
            "Item Number",
            "KNQMAN vs HJ Checked detail",
            "Root Cause",
            "Solution",
            "Owner",
            "Due Date",
            "Status",
            "Category",
            "Orphaned",
            "Scrap",
            "Product_category",
        }
    ]
    for column in numeric_columns:
        ordered[column] = _to_number(ordered[column])

    return ordered


def summarize_report(report: pd.DataFrame) -> dict[str, int]:
    return {
        "rows": int(len(report)),
        "open_rows": int((report["Status"].astype(str) != "Closed").sum()),
        "non_zero_gap_rows": int((report["GAP"] != 0).sum()),
        "non_zero_knq_hj_variance_rows": int((report["KNQ HJ Variance"] != 0).sum()),
    }


def preview_columns(report: pd.DataFrame, columns: Iterable[str], limit: int = 10) -> pd.DataFrame:
    selected = [column for column in columns if column in report.columns]
    return report.loc[:, selected].head(limit).copy()
