# this file is tested and works well by Jim,Shen on Mar.08.2025
import os
import time
from datetime import datetime

import pandas as pd
from sqlalchemy import create_engine, text
import urllib

# ===================== 基本配置 =====================
server = os.getenv("MSSQL_SERVER", "AshtonWHJSQLprod")
database = os.getenv("MSSQL_DATABASE", "AAD")

# 是否启用加密（内网一般可用 Encrypt=no；若公司策略要求 TLS，改为 True）
USE_ENCRYPTION = False  # True -> Encrypt=yes;TrustServerCertificate=yes

# ODBC 驱动名称（确保在“ODBC 数据源管理器”里已安装）
odbc_driver = "ODBC Driver 18 for SQL Server"

# 记录开始时间
start_time = time.time()

# ===================== 构造连接字符串（Windows 身份验证） =====================
encrypt_part = (
    "Encrypt=yes;TrustServerCertificate=yes;"
    if USE_ENCRYPTION
    else "Encrypt=no;"
)

odbc_str = (
    f"DRIVER={{{odbc_driver}}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Trusted_Connection=yes;"
    f"{encrypt_part}"
)

# 对连接串进行 url 编码
params = urllib.parse.quote_plus(odbc_str)

# 创建 SQLAlchemy 引擎
# fast_executemany=True 可显著加速 to_sql 的批量写入（mssql+pyodbc 专用）
engine = create_engine(
    f"mssql+pyodbc:///?odbc_connect={params}",
    fast_executemany=True,
    pool_pre_ping=True,        # 连接空闲探活，减少“已断开连接”报错
    pool_recycle=1800          # 30 分钟回收连接，避免长连接超时
)

# ===================== 测试连接 & 示例查询 =====================
try:
    with engine.connect() as conn:
        # 方式一：标准 2.x 写法（推荐）
        row = conn.execute(
            text("SELECT @@SERVERNAME AS server_name, DB_NAME() AS db_name")
        ).one()
        print("✅ SQL Server 连接成功！")
        print(f"Server: {row.server_name}, Database: {row.db_name}")

        # pandas 读取示例（配合 text）
        df = pd.read_sql(
            text("SELECT TOP 5 name, create_date FROM sys.databases ORDER BY database_id"),
            conn
        )
        print("\n前 5 个数据库：")
        print(df)

except Exception as e:
    # 打印更友好的错误信息
    print("❌ 连接或查询失败：", repr(e))
    raise
finally:
    # 记录结束时间
    end_time = time.time()
    print(f"\n执行耗时: {end_time - start_time:.2f} 秒")

# ===================== 写入示例（可选） =====================
# 需要时取消注释：
# try:
#     sample = pd.DataFrame({
#         "col_int": [1, 2, 3],
#         "col_str": ["a", "b", "c"],
#         "col_time": [datetime.now()] * 3
#     })
#     # if_exists: 'fail' | 'replace' | 'append'
#     # index=False 通常更符合表结构
#     with engine.begin() as conn:  # 事务上下文
#         sample.to_sql("##tmp_fast_exec_demo", conn, if_exists="replace", index=False)
#     print("✅ DataFrame 已写入到临时表 ##tmp_fast_exec_demo（示例）")
# except Exception as e:
#     print("❌ 写入失败：", repr(e))
