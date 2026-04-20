import pandas as pd
import pyodbc
import os
from datetime import datetime

# 数据库连接信息
server_name = "ashley-edw.database.windows.net"
database_name = "ASHLEY_EDW"

# SQL 查询
sql_query = """
SELECT  
    ActivityCodeOne, 
    ActivityCodeTwo, 
    FromRegion,
    FromWhs,
    FromArea,
    FromAisle,
    FromSection,
    FromTier,
    ToRegion,
    ToWhs,
    ToArea,
    ToAisle,
    ToSection,
    ToTier,
    [Order],
    Item,
    Serial,
    LicensePlate,
    TransQty,
    Emp,
    EmpBadge,
    SuprBadge,
    Scanner,
    Equipment,
    AddDate,
    AddTime,
    AddUser,
    AddProgram,
    Transfer,
    Trip,
    CAST(Serial AS VARCHAR(50)) AS SN
FROM 
    Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
WHERE 
    AddDate BETWEEN 20250717 AND 20250719 
    AND ActivityCodeOne = 'MV'
    AND FromWhs = '51'
    AND ActivityCodeTwo = 'SN'
    AND FromArea = 'RM'
    AND ToArea = 'HJ'
    AND Serial <> 0
"""

# 连接字符串（使用ODBC Driver 18，Azure环境需保证本地已登录AD）
conn_str = (
    "Driver={ODBC Driver 18 for SQL Server};"
    f"Server={server_name};"
    f"Database={database_name};"
    "Authentication=ActiveDirectoryIntegrated;"
    "TrustServerCertificate=yes;"
)

# 获取当前用户Downloads文件夹路径
downloads_folder = os.path.join(os.path.expanduser("~"), "Downloads")

# 构造带时间戳的文件名
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
csv_filename = f"EDW_TABLES_{timestamp}.csv"
csv_path = os.path.join(downloads_folder, csv_filename)

# 读取数据并导出为csv
with pyodbc.connect(conn_str) as conn:
    df = pd.read_sql(sql_query, conn)

# 强制 SN 列为字符串，防止科学计数
df["SN"] = df["SN"].astype(str)
df["SN"] = df["SN"].apply(lambda x: f'="{x}"')  # 确保 Excel 中显示为纯文本

# 导出为 CSV
df.to_csv(csv_path, index=False, encoding='utf-8-sig')

print(f"✅ 数据已成功导出到: {csv_path}")
