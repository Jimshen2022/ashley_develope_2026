# 导入库 / Import Libraries
import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import time
from datetime import datetime
from tabulate import tabulate

# SQL配置部分 / SQL Configuration Section
# 数据库连接参数 / Database Connection Parameters
SERVER = 'MillenniumWHJSQLprod'
DATABASE = 'AAD'

# SQL查询语句 / SQL Query
SQL_QUERY = """
            select top 10 * \
            from t_location as t \



            """

# 输出文件配置 / Output File Configuration
OUTPUT_DIR = os.path.expanduser("~/Downloads")

# Pandas 显示设置 / Pandas Display Settings

pd.set_option('display.max_columns', None)  # 显示所有列
pd.set_option('display.max_rows', None)  # 显示所有行
pd.set_option('display.width', None)  # 不限制显示宽度
pd.set_option('display.max_colwidth', None)  # 显示完整的列内容


# 辅助函数 / Helper Functions


def print_table(df, rows=20):
    """以表格形式打印DataFrame - 使用轻量级单线网格"""
    print(tabulate(df.head(rows), headers='keys', tablefmt='simple_grid', showindex=True))


# 主程序 / Main Program
# 记录开始时间
start_time = time.time()

# 创建连接URL
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)

# 创建引擎
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# 执行查询
try:
    df = pd.read_sql(SQL_QUERY, engine)
    print("查询成功！数据已加载到 DataFrame。")
    print(f"共获取 {len(df)} 行数据")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 以表格形式显示数据预览
print("数据预览（前20行）：")
print_table(df, rows=20)


# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
csv_path = os.path.join(OUTPUT_DIR, f"query_results_{current_time}.csv")

# 导出到 CSV 文件
try:
    df.to_csv(csv_path, index=False)
    print(f"\n数据已成功导出到 CSV 文件：{csv_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")
