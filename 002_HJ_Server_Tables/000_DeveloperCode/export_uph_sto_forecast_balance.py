from __future__ import annotations

import argparse
import os
from datetime import datetime
from pathlib import Path

import pandas as pd
import pyodbc


DEFAULT_SERVER = os.getenv("HJ_SERVER", "AshtonWHJSQLprod")
DEFAULT_DATABASE = os.getenv("HJ_DATABASE", "AAD")
DEFAULT_DRIVER = os.getenv("HJ_ODBC_DRIVER", "ODBC Driver 17 for SQL Server")
DEFAULT_WH_ID = os.getenv("HJ_WH_ID", "335")
DEFAULT_PICK_PUT_ID = os.getenv("HJ_PICK_PUT_ID", "UPH")
DEFAULT_ENCRYPT = os.getenv("HJ_ENCRYPT", "no")


def load_sql_query(file_name: str) -> str:
    sql_path = Path(__file__).with_name(file_name)
    sql = sql_path.read_text(encoding="utf-8-sig")
    sql = sql.replace("DECLARE @wh_id VARCHAR(10) = '335';", "DECLARE @wh_id VARCHAR(10) = ?;")
    sql = sql.replace("DECLARE @pick_put_id VARCHAR(15) = 'UPH';", "DECLARE @pick_put_id VARCHAR(15) = ?;")
    return sql


def build_connection_string(args: argparse.Namespace) -> str:
    return (
        f"DRIVER={{{args.driver}}};"
        f"SERVER={args.server};"
        f"DATABASE={args.database};"
        "Trusted_Connection=yes;"
        f"Encrypt={args.encrypt};"
        "TrustServerCertificate=yes;"
    )


def default_output_path() -> Path:
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    downloads = Path.home() / "Downloads"
    return downloads / f"uph_sto_forecast_balance_{timestamp}.xlsx"


def autofit_worksheet_columns(worksheet) -> None:
    for column_cells in worksheet.columns:
        header = str(column_cells[0].value)
        max_length = max(len(str(cell.value)) if cell.value is not None else 0 for cell in column_cells)
        worksheet.column_dimensions[column_cells[0].column_letter].width = min(max(max_length, len(header)) + 2, 60)


def export_result(
    balance_df: pd.DataFrame,
    stored_item_df: pd.DataFrame,
    demand_df: pd.DataFrame,
    output_path: Path,
) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if output_path.suffix.lower() == ".csv":
        balance_df.to_csv(output_path, index=False, encoding="utf-8-sig")
        detail_output_path = output_path.with_name(f"{output_path.stem}_stored_item_detail.csv")
        demand_output_path = output_path.with_name(f"{output_path.stem}_demand_detail.csv")
        stored_item_df.to_csv(detail_output_path, index=False, encoding="utf-8-sig")
        demand_df.to_csv(demand_output_path, index=False, encoding="utf-8-sig")
        return

    with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
        balance_df.to_excel(writer, sheet_name="UPH_Balance", index=False)
        stored_item_df.to_excel(writer, sheet_name="Stored_Item_Detail", index=False)
        demand_df.to_excel(writer, sheet_name="Demand_Detail", index=False)
        autofit_worksheet_columns(writer.sheets["UPH_Balance"])
        autofit_worksheet_columns(writer.sheets["Stored_Item_Detail"])
        autofit_worksheet_columns(writer.sheets["Demand_Detail"])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export UPH STO and forecast-demand balance from HJ SQL Server.")
    parser.add_argument("--server", default=DEFAULT_SERVER, help="SQL Server name.")
    parser.add_argument("--database", default=DEFAULT_DATABASE, help="Database name.")
    parser.add_argument("--driver", default=DEFAULT_DRIVER, help="ODBC driver name.")
    parser.add_argument("--wh-id", default=DEFAULT_WH_ID, help="HighJump warehouse id.")
    parser.add_argument("--pick-put-id", default=DEFAULT_PICK_PUT_ID, help="t_item_master.pick_put_id filter.")
    parser.add_argument("--encrypt", default=DEFAULT_ENCRYPT, choices=["yes", "no", "optional", "mandatory"], help="ODBC encryption setting.")
    parser.add_argument("--output", type=Path, default=default_output_path(), help="Output .xlsx or .csv path.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    conn_str = build_connection_string(args)
    balance_query = load_sql_query("uph_sto_forecast_balance.sql")
    stored_item_query = load_sql_query("uph_stored_item_detail.sql")
    demand_query = load_sql_query("uph_demand_detail.sql")

    print(f"Connecting to {args.server}/{args.database}, wh_id={args.wh_id}, pick_put_id={args.pick_put_id}...")
    with pyodbc.connect(conn_str) as conn:
        balance_df = pd.read_sql_query(balance_query, conn, params=[args.wh_id, args.pick_put_id])
        stored_item_df = pd.read_sql_query(stored_item_query, conn, params=[args.wh_id, args.pick_put_id])
        demand_df = pd.read_sql_query(demand_query, conn, params=[args.wh_id, args.pick_put_id])

    export_result(balance_df, stored_item_df, demand_df, args.output)
    print(
        f"Exported {len(balance_df):,} balance rows, "
        f"{len(stored_item_df):,} stored-item detail rows, and "
        f"{len(demand_df):,} demand detail rows to {args.output}"
    )


if __name__ == "__main__":
    main()
