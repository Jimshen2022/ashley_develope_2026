import sys
import urllib.parse
from datetime import datetime
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text


SERVER = "AshtonWHJSQLprod"
DATABASE = "AAD"
OUTPUT_PREFIX = "ashton_a3_x_locations"
DOWNLOADS_DIR = Path.home() / "Downloads"

SQL_QUERY = """
SELECT
    l.location_id,
    l.status,
    l.type,
    sto.onhand,
    sto.SKUs
FROM t_location AS l
LEFT JOIN (
    SELECT
        location_id,
        SUM(actual_qty) AS onhand,
        COUNT(DISTINCT item_number) AS SKUs
    FROM t_stored_item
    GROUP BY location_id
) AS sto
    ON sto.location_id = l.location_id
WHERE l.type = 'X'
  AND (sto.SKUs = 1 OR sto.SKUs IS NULL)
  AND l.location_id LIKE 'A3%'
ORDER BY l.location_id;
"""


def configure_console_encoding() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")


def get_connection_string() -> str:
    driver = "{ODBC Driver 17 for SQL Server}"
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        "Authentication=ActiveDirectoryIntegrated;"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )


def get_engine():
    params = urllib.parse.quote_plus(get_connection_string())
    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}", pool_pre_ping=True)


def build_output_path() -> Path:
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return DOWNLOADS_DIR / f"{OUTPUT_PREFIX}_{timestamp}.xlsx"


def export_query() -> Path:
    output_path = build_output_path()
    engine = get_engine()

    with engine.connect() as connection:
        df = pd.read_sql(text(SQL_QUERY), connection)

    df.to_excel(output_path, index=False)
    return output_path


def main() -> None:
    configure_console_encoding()
    print(f"Connecting to {SERVER} / {DATABASE} ...")

    try:
        output_path = export_query()
        print(f"Export complete: {output_path}")
    except Exception as exc:
        print("SQL Server connection or export failed.")
        print(exc)
        raise


if __name__ == "__main__":
    main()
