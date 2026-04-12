# this file is tested and works well by Jim,Shen on Mar.08.2025
import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import os
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

WITH mo AS (
SELECT t1.item_number, 
	t1.lot_number, 
	t1.control_number_2 as mo_nbr,
	MIN(t1.start_tran_date) as start_tran_date
FROM [PowerBI_Distribution].[TranLog] AS t1 
WHERE t1.wh_id in ('35','34','31','33') 
	AND t1.tran_type = '111'
	AND t1.start_tran_date > DATEADD(DAY, - 30, GETDATE())
group by t1.item_number, 
	t1.lot_number, 
	t1.control_number_2	
)
SELECT

    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    t3.control_number,
    t3.control_number_2,
    mo.mo_nbr,
    DATEPART(HOUR, t3.start_tran_time) AS TRAN_HOUR,
    SUM(t3.tran_qty) AS qty
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN mo ON mo.item_number = t3.item_number and mo.lot_number = t3.lot_number
WHERE t3.wh_id in ('35','31','31','34')
    AND t3.tran_type = '374'
    AND t3.start_tran_date >= CAST(GETDATE() - 21 AS DATE) -- 最近3周
    AND t3.start_tran_date <= CAST(GETDATE() AS DATE)
GROUP BY
    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    t3.control_number,
    t3.control_number_2,
    mo.mo_nbr,
    DATEPART(HOUR, t3.start_tran_time)
ORDER BY
    t3.wh_id,
    t3.item_number,
    t3.start_tran_date,
    t3.control_number,
    TRAN_HOUR;


"""

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

 # 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
file_name = f'wanek_query_{current_time}.csv'
file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)


# 导出到 csv 文件
# output_path = os.path.expanduser("~/Downloads/query_results.xlsx")
try:
    df.to_csv(file_path, index=False)
    print(f"数据已成功导出到csv文件：{file_path}")
except Exception as e:
    print("导出 csv 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")
