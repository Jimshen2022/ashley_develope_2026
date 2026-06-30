import argparse
import re
import sys
import urllib.parse
from datetime import datetime
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text


SERVER = "AshtonWHJSQLprod"
DATABASE = "AAD"
DOWNLOADS_DIR = Path.home() / "Downloads"
DEFAULT_SQL_FILE = Path(__file__).with_name("query_to_run.sql")


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


def load_sql(sql_file: Path) -> str:
    if not sql_file.exists():
        raise FileNotFoundError(f"SQL file not found: {sql_file}")

    sql_text = sql_file.read_text(encoding="utf-8-sig").strip()
    if not sql_text:
        raise ValueError(f"SQL file is empty: {sql_file}")

    return sql_text


def sanitize_file_name(name: str) -> str:
    safe_name = re.sub(r"[^A-Za-z0-9_-]+", "_", name).strip("_")
    return safe_name or "query_export"


def build_output_path(output_prefix: str) -> Path:
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return DOWNLOADS_DIR / f"{sanitize_file_name(output_prefix)}_{timestamp}.xlsx"


def export_sql_file(sql_file: Path, output_prefix: str | None = None) -> Path:
    sql_text = load_sql(sql_file)
    final_prefix = output_prefix or sql_file.stem
    output_path = build_output_path(final_prefix)

    engine = get_engine()
    with engine.connect() as connection:
        df = pd.read_sql(text(sql_text), connection)

    df.to_excel(output_path, index=False)
    print(f"Rows exported: {len(df):,}")
    return output_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run a SQL file against Ashton HJ SQL Server and export the result to Downloads."
    )
    parser.add_argument(
        "--sql-file",
        type=Path,
        default=DEFAULT_SQL_FILE,
        help="Path to the .sql file to run. Defaults to query_to_run.sql in this folder.",
    )
    parser.add_argument(
        "--output-prefix",
        help="Optional output file prefix. Defaults to the SQL file name.",
    )
    return parser.parse_args()


def main() -> None:
    configure_console_encoding()
    args = parse_args()
    sql_file = args.sql_file.resolve()

    print(f"Connecting to {SERVER} / {DATABASE} ...")
    print(f"SQL file: {sql_file}")

    try:
        output_path = export_sql_file(sql_file, args.output_prefix)
        print(f"Export complete: {output_path}")
    except Exception as exc:
        print("SQL Server connection or export failed.")
        print(exc)
        raise


if __name__ == "__main__":
    main()
