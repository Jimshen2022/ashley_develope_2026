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

-- Inventory on hand cretaed by Jim,Shen on Mar.27.2025
WITH  unit_cost AS (
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
LatestSnapshot AS (
    SELECT MAX(SnapshotDate) AS SnapshotDate 
    FROM Manufacturing_Maximo.invbalances 
    WHERE location = 'MROSTORE'
),
commodity as ( 
	select * from Manufacturing_Maximo.Commodities as t where t.itemsetid= 'VNMSET'
	)
SELECT t1.itemnum,
	t0.description,
	t0.orderunit,
	t0.issueunit,
	t0.commoditygroup,
	c.description,
	t0.itemtype,
	t0.status,
	t1.location,
	t1.binnum,
	t1.curbal as onhand,
	t1.curbal * uc.unitcost as [amount($VND)],
	t1.orgid,
	t1.siteid,
	t1.itemsetid,
	DATEADD(HOUR, 12, t1.SnapshotDate) AS SnapshotDate
FROM Manufacturing_Maximo.invbalances AS t1
JOIN LatestSnapshot ls 
    ON t1.SnapshotDate = ls.SnapshotDate
LEFT JOIN Manufacturing_Maximo.item AS t0 on t0.itemsetid = 'VNMSET' AND t1.itemnum = t0.itemnum
LEFT JOIN commodity as c on c.commodity = t0.commoditygroup
LEFT JOIN uc on uc.itemnum = t1.itemnum
--WHERE t1.location LIKE 'MROSTORE%'
    AND t1.curbal > 0
    AND trim(t1.siteid) = 'VNM.ASPM'
ORDER BY t1.itemnum


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
csv_path = os.path.join(output_dir, f"maximo_inventory_query_{current_time}.csv")
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


