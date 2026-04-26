import pyodbc
import pandas as pd
import datetime
import os
import time

# 记录开始时间
start_time = time.time()

# 数据库连接信息 (EDW - Azure SQL Database)
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'
connection_string = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"Authentication=ActiveDirectoryIntegrated;"
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
    f"Connection Timeout=120;"
)

# SQL 查询语句
sql_query = """
-- look for sn be shipped over two times
SELECT item_number, 
       lot_number, 
       start_tran_date, 
       CONVERT(VARCHAR(8), start_tran_time, 108) AS start_tran_time, 
       control_number_2
FROM Distribution_Warehouse_Wholesale.TranLog
WHERE wh_id = '335'
  AND tran_type = '347'
  AND start_tran_date >= '2026-01-01'
  AND start_tran_date <= GETDATE()
  AND lot_number IN (
      SELECT lot_number
      FROM Distribution_Warehouse_Wholesale.TranLog
      WHERE wh_id = '335'
        AND tran_type = '347'
        AND start_tran_date >= '2025-01-01'
        AND start_tran_date <= GETDATE()
      GROUP BY lot_number
      HAVING COUNT(*) >= 2
  )
ORDER BY start_tran_date, start_tran_time;
"""

# --- Helper: 用 ="..." 格式，Excel 打开时强制显示为文本，无多余空格 ---
def format_as_excel_text(val):
    if pd.isna(val) or str(val).lower() == 'nan' or str(val).strip() == '':
        return val
    return f'="{val}"'

def main():
    try:
        print("Connecting to the EDW database...")
        with pyodbc.connect(connection_string) as conn:
            print("Executing query...")
            df = pd.read_sql(sql_query, conn)
            print("Query successful! Data loaded into DataFrame.")

        # 将 item_number 和 lot_number 转为文本格式（防止 Excel 科学计数法）
        for col in ['item_number', 'lot_number']:
            if col in df.columns:
                df[col] = df[col].apply(format_as_excel_text)

        # 生成带时间戳的文件名
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

        # 获取 Downloads 文件夹路径
        downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')
        if not os.path.exists(downloads_folder):
            os.makedirs(downloads_folder)

        output_filename = f'shipped_multiple_sn_{timestamp}.csv'
        output_path = os.path.join(downloads_folder, output_filename)

        # 输出 CSV
        df.to_csv(output_path, index=False, encoding='utf-8-sig')
        print(f"Success! Query results saved to: {output_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        end_time = time.time()
        execution_time = end_time - start_time
        print(f"\nTotal execution time: {execution_time:.2f} seconds")

if __name__ == "__main__":
    main()