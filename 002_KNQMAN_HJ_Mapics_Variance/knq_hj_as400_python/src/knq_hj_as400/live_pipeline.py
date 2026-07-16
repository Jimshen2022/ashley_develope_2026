from __future__ import annotations

import pandas as pd

from knq_hj_as400.live_sql_source import HybridSqlWorkbookSource
from knq_hj_as400.pipeline import (
    FINAL_COLUMNS,
    _apply_no_variance_defaults,
    _apply_previous_annotations,
    _build_item_class_map,
    _build_knq_declared_not_hj,
    _build_orphaned_counts,
    _build_po_exception_qty,
    _build_shipped_not_invoiced,
    _build_trailer_in_yard_not_knq,
    _build_trip_exception_qty,
    _clean_text,
    _count_hj_location,
    _derive_product_category,
    _series_lookup,
    _to_number,
)


def build_live_data_report(workbook_path: str) -> pd.DataFrame:
    source = HybridSqlWorkbookSource(workbook_path)
    sheets = source.load_required_base_sheets()
    as_of_date = source.as_of_date

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
        _build_po_exception_qty(sheets["KNQ_4W_Import"], sheets["HJ_4W_Received"], as_of_date),
    )
    data["Trip"] = _series_lookup(
        data["Item Number"],
        _build_trip_exception_qty(sheets["KNQ_4W_Export"], sheets["HJ_4W_Shipped"], as_of_date),
    )
    data["Mapics Adjusted"] = _series_lookup(
        data["Item Number"],
        sheets["Adjusted"]
        .assign(ITNBR=_clean_text(sheets["Adjusted"]["ITNBR"]), Qty=_to_number(sheets["Adjusted"]["Qty"]))
        .groupby("ITNBR")["Qty"]
        .sum(),
    )
    data["NG"] = _series_lookup(
        data["Item Number"],
        sheets["HJ_NG"]
        .assign(item_number=_clean_text(sheets["HJ_NG"]["item_number"]))
        .groupby("item_number")
        .size(),
    )
    data["KNQ delared but HJ not"] = _series_lookup(
        data["Item Number"],
        _build_knq_declared_not_hj(sheets["KNQ_4W_Import"], sheets["HJ_4W_Received"], as_of_date),
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
        sheets["rollback"]
        .assign(ITNBR=_clean_text(sheets["rollback"].get("ITNBR", pd.Series(dtype="object"))), TRQTY=_to_number(sheets["rollback"].get("TRQTY", pd.Series(dtype="float64"))))
        .groupby("ITNBR")["TRQTY"]
        .sum()
        if not sheets["rollback"].empty
        else pd.Series(dtype="float64"),
    )
    data["Exception"] = _series_lookup(
        data["Item Number"],
        sheets["exception"]
        .assign(Item=_clean_text(sheets["exception"]["Item"]), Qty=_to_number(sheets["exception"]["Qty"]))
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

    item_sheet = source.fetch_sql_sheet("Item", item_numbers=data["Item Number"].tolist())
    item_class_map = _build_item_class_map(item_sheet)
    data["Product_category"] = data["Item Number"].map(
        lambda item: _derive_product_category(item, item_class_map.get(item, ""))
    )
    data = _apply_no_variance_defaults(data, as_of_date)

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
