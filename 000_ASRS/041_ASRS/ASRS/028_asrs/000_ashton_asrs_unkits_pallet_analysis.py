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

WITH itm AS (
    SELECT
        t.ITNBR AS item_number,
        t.ITDSC AS description,
        t.BZCQCD AS uom,
        'FG' AS inventory_type,
        t.ITCLS AS commodity_code,
        t.STID AS wh_id,
        'PAL5H' AS class_id,
        t.WEGHT AS unit_weight,
        t.B2Z95S AS unit_volume,
        t.B2Z95S AS nested_volume,
        'PALLT' AS pick_put_id,
        '5x5' AS pallet_id,
        CASE
            WHEN t.B2Z95S = 0 THEN ROUND(172.2441 / 2.167, 2)
            ELSE ROUND(172.2441 / t.B2Z95S, 2)
        END AS std_hand_qty,
        'CG' AS product
    FROM MasterData_ItemMaster_MIL.ITMRVA AS t
    WHERE STID = '51' AND (ITCLS LIKE 'Z%K' OR ITCLS = 'WVVG')
)

SELECT
    t0.HOUSE AS wh_id,
    t0.TCODE AS tran_type,
    'Shipment' AS description,
    CAST('20'+RIGHT(t0.UPDDT,6) AS DATE) AS start_tran_date,
    t0.ITNBR AS item_number,
    'CG' AS product,
    3 AS pallet_id,
    SUM(t0.TRQTY) AS qty
FROM Manufacturing_Inventory_MIL.IMHIST AS t0
LEFT JOIN itm ON itm.item_number = t0.ITNBR
WHERE t0.HOUSE = '51'
  AND t0.TCODE = 'SA'
  AND CAST('20' + RIGHT(t0.UPDDT, 6) AS DATE) >= CAST(GETDATE() - 91 AS DATE)
  AND (itm.commodity_code LIKE 'Z%K' OR itm.commodity_code = 'WVVG')
GROUP BY
    t0.HOUSE,
    t0.TCODE,
    t0.UPDDT,
    t0.ITNBR
ORDER BY
    t0.HOUSE,
    t0.ITNBR,
    t0.UPDDT
    
    
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
        index=['wh_id', 'tran_type', 'description', 'item_number', 'product', 'pallet_id', 'pallet_type'],
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
filename = f"ashton_Unkits_analysis_{timestamp}.xlsx"
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
