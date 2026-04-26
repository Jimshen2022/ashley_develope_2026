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

WITH unit_cost AS (
    SELECT 
        t0.itemnum, 
        t0.unitcost,
        ROW_NUMBER() OVER (PARTITION BY t0.itemnum ORDER BY t0.transdate DESC) AS rn
    FROM Manufacturing_Maximo.MatUseTrans AS t0
    WHERE t0.siteid = 'VNM.ASPM' 
        AND t0.unitcost <> 0
),
uc as 
(
SELECT 
    itemnum,
    unitcost
FROM Unit_cost
WHERE rn = 1
),
commodity as ( 
	select * from Manufacturing_Maximo.Commodities as t where t.itemsetid= 'VNMSET'
	)
SELECT *,
    CAST(t1.transdate AS DATE) AS transaction_date,
    YEAR(t1.transdate) AS transaction_year,
    MONTH(t1.transdate) AS transaction_month,
    CASE 
        WHEN t1.unitcost > 0 THEN t1.linecost
        WHEN t1.unitcost = 0 AND uc.unitcost > 0 THEN uc.unitcost * ABS(t1.quantity) 
        ELSE 0 
    END AS issued_cost
FROM Manufacturing_Maximo.Matrectrans as t1
LEFT JOIN Manufacturing_Maximo.item AS t0 on t0.itemsetid = 'VNMSET' AND t1.itemnum = t0.itemnum
LEFT JOIN commodity as c on c.commodity = t0.commoditygroup
LEFT JOIN uc on uc.itemnum = t1.itemnum
WHERE t1.siteid = 'VNM.ASPM' 
ORDER BY t1.transdate DESC


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
output_dir = os.path.expanduser("~/Downloads")
# output_path = os.path.join(output_dir, f"query_results_{current_time}.xlsx")
csv_path = os.path.join(output_dir, f"mamimo_transfer_trx_{current_time}.csv")
# html_path = os.path.join(output_dir, f"data_view_{current_time}.html")

# 导出到 CSV 文件
try:
    df.to_csv(csv_path, index=False)
    print(f"数据已成功导出到 CSV 文件：{csv_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)


# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")


