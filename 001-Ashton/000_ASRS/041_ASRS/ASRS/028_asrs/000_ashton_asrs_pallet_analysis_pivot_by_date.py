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
WITH itm AS
(SELECT
     a.item_number
    ,a.description
    ,a.uom
    ,a.inventory_type
    ,a.commodity_code
    ,a.wh_id
    ,a.class_id
    ,a.unit_weight
    ,a.unit_volume
    ,a.nested_volume
    ,a.pick_put_id
    ,a.pallet_id
    ,a.std_hand_qty
    ,CASE
        WHEN a.pick_put_id =  'UPH' THEN 'UPH'
        ELSE 'CG'
    END AS product
FROM Distribution_Warehouse_Wholesale.t_item_master AS a
WHERE a.wh_id = '335'
)
SELECT
    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    itm.product,
    itm.pallet_id,
    itm.std_hand_qty,
    SUM(t3.tran_qty) AS qty
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN itm ON itm.item_number = t3.item_number
WHERE t3.wh_id in ('335')
    AND t3.tran_type = '347'
    AND t3.start_tran_date >= CAST(GETDATE() - 90 AS DATE)
    AND t3.start_tran_date <= CAST(GETDATE() AS DATE)
GROUP BY
    t3.wh_id,
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    itm.product,
    itm.pallet_id,
    itm.std_hand_qty
ORDER BY
    t3.wh_id,
    t3.item_number,
    t3.start_tran_date
"""

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("行数:", len(df))
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 添加 pallet_type 分类列
pallet_map = {
    1: '5x5',
    3: '5x7',
    4: '3.5x5',
    5: '3.5x7',
    16: 'no_skid',
    18: '5x8'
}
df['pallet_type'] = df['pallet_id'].map(pallet_map).fillna('unknown')

# 确保 start_tran_date 是 datetime 类型，并排序
df['start_tran_date'] = pd.to_datetime(df['start_tran_date'])
sorted_dates = sorted(df['start_tran_date'].unique())

# Pivot 操作（按照日期升序排列列）
try:
    pivot_df = df.pivot_table(
        index=['wh_id', 'tran_type', 'description', 'item_number', 'product', 'pallet_id', 'pallet_type','std_hand_qty'],
        columns='start_tran_date',
        values='qty',
        aggfunc='sum',
        fill_value=0
    ).reindex(columns=sorted_dates, level=0).reset_index()

    pivot_df.columns.name = None  # 清除列名上的层级名称
    print("已成功生成 Pivot 表，并按日期升序排列。")
except Exception as e:
    print("生成 Pivot 表失败！", e)
    exit()

# 导出到 Excel 文件
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
filename = f"query_results_{timestamp}.xlsx"
output_path = os.path.expanduser(f"~/Downloads/{filename}")
try:
    pivot_df.to_excel(output_path, index=False, engine='openpyxl')
    print(f"数据已成功导出到 Excel 文件：{output_path}")
except Exception as e:
    print("导出 Excel 文件失败！", e)

# 运行时长
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")
