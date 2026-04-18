import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import time
from datetime import datetime

# 记录开始时间
start_time = time.time()

# 数据库连接信息
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'

# 创建连接URL
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)

# 创建引擎
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# SQL 查询语句
query = """

WITH WA AS (
    SELECT *, 
        SUBSTRING(LEFT(t.transaction_string, 21), 12, 10) AS trip_nbr_2
    FROM Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t
    WHERE t.imported > DATEADD(DAY, -120, GETDATE())
        AND t.transaction_string LIKE 'L%' 
        AND RIGHT(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10),2) <> '00'
),
sub_trip_imported AS (
    SELECT  
        *, 
        CAST(LEFT(trip_nbr_2, 7) AS INT) AS trip_nbr
    FROM WA
    --WHERE trip_nbr_2 LIKE '%46064%'
),
tran_with_datetime AS (
    SELECT 
        t1.tran_type,
        t1.description,
        t1.employee_id,
        t1.control_number_2,
        t1.start_tran_date,
		CONVERT(VARCHAR(8), t1.start_tran_time, 108) AS start_tran_time,
        t1.tran_qty,
        CAST(CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS DATETIME) AS start_tran_datetime
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    WHERE t1.wh_id = '335'
        AND t1.start_tran_date > DATEADD(DAY, -90, GETDATE())
        AND t1.tran_type IN ('350')
	--	AND t1.control_number_2 LIKE '%46064%'
),
ranked_tran AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY tran_type, description, control_number_2
            ORDER BY start_tran_datetime
        ) AS rn
    FROM tran_with_datetime
),
fill as (
SELECT 
    tran_type,
    description,
    employee_id,
    control_number_2,
    start_tran_date,
    start_tran_time,
    start_tran_datetime,
    tran_qty	
FROM ranked_tran as a
WHERE rn = 1
)
SELECT t0.*,
	b.imported,
	--CONVERT(VARCHAR(10),b.imported,120) + ' ' + CONVERT(VARCHAR(8),b.imported,108)  as imported_into_HJ_time,
	b.trip_nbr,
	b.trip_nbr_2
FROM fill as t0
LEFT JOIN sub_trip_imported as b ON CAST(LEFT(t0.control_number_2,7) AS INT) = b.trip_nbr
WHERE b.trip_nbr_2 IS NOT NULL
ORDER BY b.trip_nbr_2
    
"""

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("行数:", len(df))
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 导出到 Excel 文件
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
filename = f"query_results_{timestamp}.xlsx"
output_path = os.path.expanduser(f"~/Downloads/{filename}")
try:
    df.to_excel(output_path, index=False, engine='openpyxl')
    print(f"数据已成功导出到 Excel 文件：{output_path}")
except Exception as e:
    print("导出 Excel 文件失败！", e)

# 运行时长
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")
