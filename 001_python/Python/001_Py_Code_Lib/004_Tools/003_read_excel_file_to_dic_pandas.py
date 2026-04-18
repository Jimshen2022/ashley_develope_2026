import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import os
import time

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

SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335')
  AND t1.start_tran_date = '2025-01-06'
  AND t1.tran_type IN ('151');


"""

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 导出到 Excel 文件
output_path = os.path.expanduser("~/Downloads/query_results.xlsx")
try:
    df.to_excel(output_path, index=False, engine='openpyxl')
    print(f"数据已成功导出到 Excel 文件：{output_path}")
except Exception as e:
    print("导出 Excel 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")