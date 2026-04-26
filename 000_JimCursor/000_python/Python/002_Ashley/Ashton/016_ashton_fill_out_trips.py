import pyodbc
import pandas as pd
import os
import time
from datetime import datetime
import webbrowser

# 记录开始时间
start_time = time.time()

# 数据库连接信息
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'
connection_string = (
    f"DRIVER={{ODBC Driver 18 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"Authentication=ActiveDirectoryIntegrated;"  # 使用 Azure AD 集成验证
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
    f"Connection Timeout=120;"
)

# SQL 查询语句
query = """

WITH fill_trips AS (
    SELECT LEFT(t1.control_number_2, 7) * 1 AS trip_nbr
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    WHERE t1.wh_id = '335'
      AND t1.start_tran_date > '2025-01-01'
      AND t1.tran_type = '347'
      AND t1.control_number_2 NOT LIKE '%-00'
      AND ISNUMERIC(LEFT(t1.control_number_2, 7)) = 1
),
i AS (
    SELECT
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    WHERE t0.STID = '335'
)
SELECT
    t1.start_tran_date,
    t1.tran_type,
    t1.description,
    t1.control_number_2,
    TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)) AS trip_nbr,
    t1.item_number,
    ROW_NUMBER() OVER (
        PARTITION BY TRY_CONVERT(INT, LEFT(t1.control_number_2, 7))
        ORDER BY t1.start_tran_date
    ) AS rn,
    CASE
        WHEN ROW_NUMBER() OVER (
            PARTITION BY TRY_CONVERT(INT, LEFT(t1.control_number_2, 7))
            ORDER BY t1.start_tran_date
        ) = 1 THEN 1
        ELSE 0
    END AS trips_count,
CASE
    WHEN t1.control_number_2 LIKE '%-00' THEN 0 -- 如果以 '-00' 结尾
    WHEN ROW_NUMBER() OVER (
            PARTITION BY t1.control_number_2
            ORDER BY t1.control_number_2
        ) = 1 THEN 1 -- 第一行
    ELSE 0 -- 其他情况
    END AS sub_trips_count,
    CASE
        WHEN t1.control_number_2 NOT LIKE '%-00' THEN 'sub-trip'
        ELSE 'main_trip'
    END AS trip_type,
    SUM(t1.tran_qty) AS tran_qty,
    SUM(t1.tran_qty) * i.B2Z95S AS Cubes
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN i ON i.ITNBR = t1.item_number
INNER JOIN fill_trips AS trips ON TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)) = trips.trip_nbr
WHERE t1.wh_id = '335'
  AND t1.start_tran_date > '2025-01-01'
  AND t1.tran_type = '347'
  AND ISNUMERIC(LEFT(t1.control_number_2, 7)) = 1
GROUP BY
    t1.start_tran_date,
    t1.tran_type,
    t1.description,
    t1.control_number_2,
    TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)),
    t1.item_number,
    i.B2Z95S,
    CASE
        WHEN t1.control_number_2 NOT LIKE '%-00' THEN 'sub-trip'
        ELSE 'main_trip'
    END
ORDER BY TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)), t1.start_tran_date;
  
  
"""

# 连接到数据库并执行查询
try:
    print("正在连接数据库...")
    with pyodbc.connect(connection_string) as conn:
        # 将查询结果加载到 pandas DataFrame
        print("正在执行查询...")
        df = pd.read_sql(query, conn)
        print(f"查询成功！获取到 {len(df)} 行数据。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 显示数据预览
print("\n数据预览（前5行）:")
print(df.head(5).to_string())

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
# output_path = os.path.join(output_dir, f"query_results_{current_time}.xlsx")
csv_path = os.path.join(output_dir, f"query_results_{current_time}.csv")
# html_path = os.path.join(output_dir, f"data_view_{current_time}.html")

# 导出到 CSV 文件
try:
    df.to_csv(csv_path, index=False)
    print(f"数据已成功导出到 CSV 文件：{csv_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)

# print(f"1. 打开Excel文件查看数据: {output_path}")

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")

