# this file follows the EDW connection setup tested by Jim, Shen on Mar.08.2025
import os
import time
import urllib
from datetime import datetime

import pandas as pd
import pyodbc
from sqlalchemy import create_engine

server = os.getenv("EDW_SERVER", "ashley-edw.database.windows.net")
database = os.getenv("EDW_DATABASE", "ASHLEY_EDW")
authentication = os.getenv("EDW_AUTHENTICATION", "ActiveDirectoryIntegrated")
connection_timeout = os.getenv("EDW_CONNECT_TIMEOUT", "300")


def get_edw_driver():
    driver = os.getenv("EDW_DRIVER")
    if driver:
        return driver

    drivers = pyodbc.drivers()
    if "ODBC Driver 17 for SQL Server" in drivers:
        return "ODBC Driver 17 for SQL Server"
    if "ODBC Driver 18 for SQL Server" in drivers:
        return "ODBC Driver 18 for SQL Server"
    return "ODBC Driver 17 for SQL Server"


QUERY = """
SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335')
  AND t1.start_tran_date = '2026-04-26'
  AND t1.tran_type IN ('151');
"""


def create_edw_engine():
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


def main():
    start_time = time.time()
    engine = create_edw_engine()

    try:
        df = pd.read_sql(QUERY, engine)
        print("查询成功！数据已加载到 DataFrame。")
    except Exception as e:
        print("数据库连接或查询失败！", e)
        raise SystemExit(1)

    current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = os.path.expanduser("~/Downloads")
    os.makedirs(output_dir, exist_ok=True)
    csv_path = os.path.join(output_dir, f"query_results_{current_time}.csv")

    try:
        df.to_csv(csv_path, index=False)
        print(f"数据已成功导出到 CSV 文件：{csv_path}")
    except Exception as e:
        print("导出 CSV 文件失败！", e)
        raise SystemExit(1)

    end_time = time.time()
    execution_time = end_time - start_time
    print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == "__main__":
    main()
