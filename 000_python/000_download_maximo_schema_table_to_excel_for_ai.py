# this file follows the EDW connection setup tested by Jim Shen
# Purpose:
#   Download TOP 100 rows from each Manufacturing_Maximo table.
#   If the table has a siteid field, apply: WHERE siteid = 'VNM.ASPM'
#   Export each table to one Excel file under user's Downloads folder.

import os
import re
import time
import urllib
from datetime import datetime

import pandas as pd
import pyodbc
from sqlalchemy import create_engine, text


# =========================
# EDW Connection Settings
# =========================

server = os.getenv("EDW_SERVER", "ashley-edw.database.windows.net")
database = os.getenv("EDW_DATABASE", "ASHLEY_EDW")
authentication = os.getenv("EDW_AUTHENTICATION", "ActiveDirectoryIntegrated")
connection_timeout = os.getenv("EDW_CONNECT_TIMEOUT", "300")


def get_edw_driver():
    """
    Auto-detect installed SQL Server ODBC driver.
    Priority:
      1. Environment variable EDW_DRIVER
      2. ODBC Driver 17 for SQL Server
      3. ODBC Driver 18 for SQL Server
      4. Default to ODBC Driver 17
    """
    driver = os.getenv("EDW_DRIVER")
    if driver:
        return driver

    drivers = pyodbc.drivers()

    if "ODBC Driver 17 for SQL Server" in drivers:
        return "ODBC Driver 17 for SQL Server"

    if "ODBC Driver 18 for SQL Server" in drivers:
        return "ODBC Driver 18 for SQL Server"

    return "ODBC Driver 17 for SQL Server"


def create_edw_engine():
    """
    Create SQLAlchemy engine for Azure SQL EDW.
    """
    params = urllib.parse.quote_plus(
        f"DRIVER={{{get_edw_driver()}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"Authentication={authentication};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        f"Connection Timeout={connection_timeout};"
    )

    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}")


# =========================
# Table List
# =========================

TABLES = [
    "Manufacturing_Maximo.a_serviceaddress",
    "Manufacturing_Maximo.alndomain",
    "Manufacturing_Maximo.asset",
    "Manufacturing_Maximo.AssetAttribute",
    "Manufacturing_Maximo.Assetlocusercust",
    "Manufacturing_Maximo.AssetMeter",
    "Manufacturing_Maximo.AssetSpec",
    "Manufacturing_Maximo.Assignment",
    "Manufacturing_Maximo.classstructure",
    "Manufacturing_Maximo.Commodities",
    "Manufacturing_Maximo.companies",
    "Manufacturing_Maximo.Contract",
    "Manufacturing_Maximo.Contractline",
    "Manufacturing_Maximo.Contractmaster",
    "Manufacturing_Maximo.FailureRemark",
    "Manufacturing_Maximo.FailureReport",
    "Manufacturing_Maximo.GlComponents",
    "Manufacturing_Maximo.invbalances",
    "Manufacturing_Maximo.invcost",
    "Manufacturing_Maximo.inventory",
    "Manufacturing_Maximo.Invlot",
    "Manufacturing_Maximo.Invoicecost",
    "Manufacturing_Maximo.Invoiceline",
    "Manufacturing_Maximo.Invreserve",
    "Manufacturing_Maximo.Invtrans",
    "Manufacturing_Maximo.Invuseline",
    "Manufacturing_Maximo.InvVendor",
    "Manufacturing_Maximo.item",
    "Manufacturing_Maximo.Itemorginfo",
    "Manufacturing_Maximo.Jobitem",
    "Manufacturing_Maximo.Joblabor",
    "Manufacturing_Maximo.Jobplan",
    "Manufacturing_Maximo.Jobtask",
    "Manufacturing_Maximo.labor",
    "Manufacturing_Maximo.LaborData",
    "Manufacturing_Maximo.labtrans",
    "Manufacturing_Maximo.Locations",
    "Manufacturing_Maximo.Lochierarchy",
    "Manufacturing_Maximo.MachineMaintenance",
    "Manufacturing_Maximo.MachineOperatorPM",
    "Manufacturing_Maximo.MachinePIVComplianceMetric",
    "Manufacturing_Maximo.MachinePIVDTperCAMetric",
    "Manufacturing_Maximo.MachinePIVReactiveCorrective",
    "Manufacturing_Maximo.MachinePIVTargetStartMetric",
    "Manufacturing_Maximo.Masterpm",
    "Manufacturing_Maximo.Matrectrans",
    "Manufacturing_Maximo.MatUseTrans",
    "Manufacturing_Maximo.meterreading",
    "Manufacturing_Maximo.numericdomain",
    "Manufacturing_Maximo.organization",
    "Manufacturing_Maximo.person",
    "Manufacturing_Maximo.Phone",
    "Manufacturing_Maximo.Plusgincevent",
    "Manufacturing_Maximo.Plusgincperson",
    "Manufacturing_Maximo.Plusginevent",
    "Manufacturing_Maximo.Plusginjorill",
    "Manufacturing_Maximo.Plusgoutcome",
    "Manufacturing_Maximo.plustassetalias",
    "Manufacturing_Maximo.Plustassetsthist",
    "Manufacturing_Maximo.Plustcomp",
    "Manufacturing_Maximo.Plustitemwarr",
    "Manufacturing_Maximo.Plustpos",
    "Manufacturing_Maximo.Plustwoasset",
    "Manufacturing_Maximo.Plustwpserv",
    "Manufacturing_Maximo.Pm",
    "Manufacturing_Maximo.PmMeter",
    "Manufacturing_Maximo.Po",
    "Manufacturing_Maximo.Poline",
    "Manufacturing_Maximo.serviceaddress",
    "Manufacturing_Maximo.Servrectrans",
    "Manufacturing_Maximo.site",
    "Manufacturing_Maximo.Synonymdomain",
    "Manufacturing_Maximo.Ticket",
    "Manufacturing_Maximo.Warrantyline",
    "Manufacturing_Maximo.WorkOrder",
    "Manufacturing_Maximo.WPitem",
    "Manufacturing_Maximo.WPlabor",
    "Manufacturing_Maximo.vnprline",
    "Manufacturing_Maximo.vnpr",
]


# =========================
# Helper Functions
# =========================

def split_schema_table(full_table_name):
    """
    Convert 'Manufacturing_Maximo.asset' to:
      schema_name = 'Manufacturing_Maximo'
      table_name = 'asset'
    """
    parts = full_table_name.split(".")

    if len(parts) != 2:
        raise ValueError(f"Invalid table name format: {full_table_name}")

    return parts[0], parts[1]


def safe_excel_file_name(full_table_name):
    """
    Create safe Excel file name.
    Example:
      Manufacturing_Maximo.asset -> Manufacturing_Maximo.asset.xlsx
    """
    safe_name = re.sub(r'[\\/:*?"<>|]', "_", full_table_name)
    return f"{safe_name}.xlsx"


def get_table_columns(engine, schema_name, table_name):
    """
    Get all columns from INFORMATION_SCHEMA.COLUMNS.
    """
    sql = text("""
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = :schema_name
          AND TABLE_NAME = :table_name
        ORDER BY ORDINAL_POSITION;
    """)

    df_columns = pd.read_sql(
        sql,
        engine,
        params={
            "schema_name": schema_name,
            "table_name": table_name,
        },
    )

    return df_columns["COLUMN_NAME"].tolist()


def find_siteid_column(columns):
    """
    Check whether table has siteid column.
    Return real column name if found, otherwise return None.
    Handles siteid / SITEID / SiteId.
    """
    for col in columns:
        if col.lower() == "siteid":
            return col

    return None


def build_query(schema_name, table_name, siteid_column=None):
    """
    Build TOP 100 query.
    If siteid exists, add WHERE siteid = 'VNM.ASPM'.
    """
    full_table = f"[{schema_name}].[{table_name}]"

    if siteid_column:
        query = f"""
            SELECT TOP 100 *
            FROM {full_table}
            WHERE [{siteid_column}] = 'VNM.ASPM';
        """
    else:
        query = f"""
            SELECT TOP 100 *
            FROM {full_table};
        """

    return query


def export_table_to_excel(engine, full_table_name, output_dir):
    """
    Export one table to Excel.
    Return log dictionary.
    """
    start_time = time.time()

    schema_name, table_name = split_schema_table(full_table_name)
    output_file = os.path.join(output_dir, safe_excel_file_name(full_table_name))

    log = {
        "table_name": full_table_name,
        "has_siteid": "",
        "siteid_filter": "",
        "row_count": 0,
        "status": "",
        "output_file": output_file,
        "error_message": "",
        "execution_seconds": 0,
    }

    try:
        print(f"\nProcessing: {full_table_name}")

        columns = get_table_columns(engine, schema_name, table_name)

        if not columns:
            raise Exception("Table not found or no columns returned from INFORMATION_SCHEMA.COLUMNS.")

        siteid_column = find_siteid_column(columns)

        if siteid_column:
            log["has_siteid"] = "Y"
            log["siteid_filter"] = f"{siteid_column} = 'VNM.ASPM'"
            print(f"  siteid column found: {siteid_column}, applying filter.")
        else:
            log["has_siteid"] = "N"
            log["siteid_filter"] = ""
            print("  siteid column not found, no siteid filter.")

        query = build_query(schema_name, table_name, siteid_column)

        df = pd.read_sql(query, engine)

        log["row_count"] = len(df)

        df.to_excel(output_file, index=False)

        log["status"] = "Success"

        print(f"  Success: {len(df)} rows exported to {output_file}")

    except Exception as e:
        log["status"] = "Failed"
        log["error_message"] = str(e)
        print(f"  Failed: {full_table_name}")
        print(f"  Error: {e}")

    finally:
        end_time = time.time()
        log["execution_seconds"] = round(end_time - start_time, 2)

    return log


# =========================
# Main Program
# =========================

def main():
    program_start_time = time.time()

    current_time = datetime.now().strftime("%Y%m%d_%H%M%S")

    downloads_dir = os.path.expanduser("~/Downloads")
    output_dir = os.path.join(downloads_dir, f"Maximo_100rows_{current_time}")

    os.makedirs(output_dir, exist_ok=True)

    print("=" * 80)
    print("Maximo table export started.")
    print(f"Server: {server}")
    print(f"Database: {database}")
    print(f"Authentication: {authentication}")
    print(f"ODBC Driver: {get_edw_driver()}")
    print(f"Output folder: {output_dir}")
    print("=" * 80)

    try:
        engine = create_edw_engine()
    except Exception as e:
        print("Failed to create EDW engine.")
        print(e)
        raise SystemExit(1)

    logs = []

    for full_table_name in TABLES:
        log = export_table_to_excel(
            engine=engine,
            full_table_name=full_table_name,
            output_dir=output_dir,
        )
        logs.append(log)

    log_df = pd.DataFrame(logs)

    log_file = os.path.join(output_dir, f"export_log_{current_time}.xlsx")

    try:
        log_df.to_excel(log_file, index=False)
        print(f"\nExport log saved to: {log_file}")
    except Exception as e:
        print("\nFailed to save export log.")
        print(e)

    success_count = len(log_df[log_df["status"] == "Success"])
    failed_count = len(log_df[log_df["status"] == "Failed"])

    program_end_time = time.time()
    total_seconds = round(program_end_time - program_start_time, 2)

    print("\n" + "=" * 80)
    print("Maximo table export finished.")
    print(f"Total tables: {len(TABLES)}")
    print(f"Success: {success_count}")
    print(f"Failed: {failed_count}")
    print(f"Output folder: {output_dir}")
    print(f"Total execution time: {total_seconds} seconds")
    print("=" * 80)


if __name__ == "__main__":
    main()