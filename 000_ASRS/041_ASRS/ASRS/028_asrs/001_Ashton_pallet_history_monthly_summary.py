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
    "DRIVER={ODBC Driver 17 for SQL Server};"
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
 WITH pallt AS (
    SELECT 
        t.wh_id,
        t.item_number,
        t.commodity_code,
        t.[description],
        t.class_id,
        t.std_hand_qty,
        t.pallet_id,
        t.unit_volume,
        t.pick_put_id
    FROM Distribution_Warehouse_Wholesale.t_item_master AS t 
    WHERE t.wh_id = '335' AND t.pick_put_id = 'PALLT'
),
ranked AS (
    SELECT 
        i.*,
        ROW_NUMBER() OVER (
            PARTITION BY i.item_number
            ORDER BY
                CASE WHEN NULLIF(LTRIM(RTRIM(i.pallet_id)), '') IS NOT NULL THEN 0 ELSE 1 END,
                CASE WHEN i.unit_volume IS NOT NULL THEN 0 ELSE 1 END,
                i.item_number
        ) AS rn
    FROM pallt AS i
),
itm AS (
    SELECT
        wh_id, item_number, commodity_code, [description],
        class_id, std_hand_qty, pallet_id, unit_volume, pick_put_id
    FROM ranked
    WHERE rn = 1
),
agg AS (
    SELECT 
        t.Warehouse as wh_id,
        t.ItemNumber as item_number,
        t.DateWeekEnding as [date],
        SUM(t.OnHandQty) AS OnHandQty   
    FROM Inventory_Enh_History.ItemBalance AS t
    WHERE t.Warehouse = '335'
      AND t.DateWeekEnding >= '2025-01-01'
    GROUP BY t.Warehouse, t.ItemNumber, t.DateWeekEnding
),
pt as (
SELECT 
    a.wh_id,
    a.item_number,
    i.class_id,
    i.std_hand_qty,
    i.pallet_id,
    case 
        when i.pallet_id = 1 then '5x5'
        when i.pallet_id = 3 then '5x7'
        when i.pallet_id = 4 then '3.5x5'
        when i.pallet_id = 5 then '3.5x7'
        when i.pallet_id = 16 then 'Bulk'
        when i.pallet_id = 18 then '5x8'
    else 'Check' End as pallet_type,
    i.unit_volume,
    i.pick_put_id,
    a.[date],
    a.OnHandQty,
    -- 向上取整的托盘数（std_hand_qty 为 0/NULL 时返回 NULL）
    a.OnHandQty / NULLIF(i.std_hand_qty, 0) AS pallets,
    a.OnHandQty * NULLIF(i.unit_volume, 0) AS cubes

FROM agg AS a
LEFT JOIN itm AS i 
  ON i.item_number = a.item_number
WHERE i.pick_put_id IN ('PALLT','FLOOR') 
    AND a.OnHandQty >0
)
SELECT p.pallet_type,
    p.[date],
    SUM(p.OnHandQty) AS OnHandQty,
    sum(p.cubes) as cubes,
    SUM(p.pallets) as pallets,
    CASE 
        WHEN SUM(p.OnHandQty) = 0 THEN 0
    ELSE 
         NULLIF(1.0 * SUM(p.OnHandQty)  / NULLIF(SUM(p.pallets), 0), 0)
    END AS avg_piece_per_pallets
FROM pt as p
GROUP BY p.pallet_type,
    p.[date]
ORDER BY p.[date]
        """

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 转换日期列为datetime类型
df['date'] = pd.to_datetime(df['date'])

# 添加年月列用于分组
df['year_month'] = df['date'].dt.strftime('%Y-%m')

# 创建月度汇总数据透视表
monthly_summary = df.groupby(['pallet_type', 'year_month']).agg({
    'OnHandQty': 'sum',
    'pallets': 'sum',
    'cubes': 'sum'
}).reset_index()

# 计算平均每托盘件数
monthly_summary['avg_pieces_per_pallet'] = (
        monthly_summary['OnHandQty'] / monthly_summary['pallets']
)

# 1. 创建透视表：平均每托盘件数
pivot_avg_pieces = monthly_summary.pivot(
    index='pallet_type',
    columns='year_month',
    values='avg_pieces_per_pallet'
)
pivot_avg_pieces = pivot_avg_pieces.reset_index()

# 2. 创建透视表：OnHand Qty百分比分布
pivot_qty_pct = monthly_summary.pivot(
    index='pallet_type',
    columns='year_month',
    values='OnHandQty'
)

# 计算每列的百分比
for col in pivot_qty_pct.columns:
    pivot_qty_pct[col] = (pivot_qty_pct[col] / pivot_qty_pct[col].sum() * 100).round(2)

# 添加Grand Total列（所有月份的平均百分比）
pivot_qty_pct['Grand Total'] = pivot_qty_pct.mean(axis=1).round(2)

# 添加Grand Total行
grand_total_row = pivot_qty_pct.sum(axis=0).round(2)
pivot_qty_pct.loc['Grand Total'] = grand_total_row

pivot_qty_pct = pivot_qty_pct.reset_index()
pivot_qty_pct.rename(columns={'pallet_type': 'Pallet Type'}, inplace=True)

# 3. 创建透视表：Bulk的平均立方英尺/件数
bulk_data = monthly_summary[monthly_summary['pallet_type'] == 'Bulk'].copy()
if not bulk_data.empty:
    bulk_data['avg_cubes_per_piece'] = bulk_data['cubes'] / bulk_data['OnHandQty']
    pivot_bulk_cbm = bulk_data.pivot(
        index='pallet_type',
        columns='year_month',
        values='avg_cubes_per_piece'
    )

    # 添加Grand Total列
    pivot_bulk_cbm['Grand Total'] = pivot_bulk_cbm.mean(axis=1).round(2)

    pivot_bulk_cbm = pivot_bulk_cbm.reset_index()
    pivot_bulk_cbm.rename(columns={'pallet_type': 'Row Labels'}, inplace=True)
else:
    pivot_bulk_cbm = pd.DataFrame()

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
csv_detail_path = os.path.join(output_dir, f"001_Ashton_pallet_history_detail_{current_time}.csv")
csv_avg_pieces_path = os.path.join(output_dir, f"002_Ashton_avg_pieces_per_pallet_{current_time}.csv")
csv_qty_pct_path = os.path.join(output_dir, f"003_Ashton_onhand_qty_percentage_{current_time}.csv")
csv_bulk_cbm_path = os.path.join(output_dir, f"004_Ashton_bulk_avg_cubes_per_piece_{current_time}.csv")

# 导出到多个 CSV 文件
try:
    # 导出详细数据
    df.drop('year_month', axis=1).to_csv(csv_detail_path, index=False)
    print(f"详细数据已成功导出到：{csv_detail_path}")

    # 导出平均每托盘件数（添加Grand Total列）
    pivot_avg_pieces_export = pivot_avg_pieces.copy()
    # 计算每行的平均值作为Grand Total
    numeric_cols = [col for col in pivot_avg_pieces_export.columns if col != 'pallet_type']
    pivot_avg_pieces_export['Grand Total'] = pivot_avg_pieces_export[numeric_cols].mean(axis=1).round(2)
    pivot_avg_pieces_export.to_csv(csv_avg_pieces_path, index=False)
    print(f"平均每托盘件数已成功导出到：{csv_avg_pieces_path}")

    # 导出OnHand Qty百分比分布
    pivot_qty_pct.to_csv(csv_qty_pct_path, index=False)
    print(f"OnHand Qty百分比分布已成功导出到：{csv_qty_pct_path}")

    # 导出Bulk立方英尺数据（如果存在）
    if not pivot_bulk_cbm.empty:
        pivot_bulk_cbm.to_csv(csv_bulk_cbm_path, index=False)
        print(f"Bulk平均立方英尺/件数已成功导出到：{csv_bulk_cbm_path}")

except Exception as e:
    print("导出 CSV 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")