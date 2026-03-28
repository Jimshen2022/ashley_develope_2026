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
    END AS avg_piece_per_pallets,
    COUNT(DISTINCT p.item_number) AS unique_sku_count
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
    'pallets': 'sum'
}).reset_index()

# 计算平均每托盘件数
monthly_summary['avg_pieces_per_pallet'] = (
        monthly_summary['OnHandQty'] / monthly_summary['pallets']
)

# 创建透视表，pallet_type作为行，年月作为列
pivot_table = monthly_summary.pivot(
    index='pallet_type',
    columns='year_month',
    values='avg_pieces_per_pallet'
)

# 重置索引使pallet_type成为普通列
pivot_table = pivot_table.reset_index()

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
csv_detail_path = os.path.join(output_dir, f"001_Ashton_pallet_history_detail_{current_time}.csv")
csv_summary_path = os.path.join(output_dir, f"001_Ashton_pallet_history_monthly_summary_{current_time}.csv")

# 导出到两个 CSV 文件
try:
    # 导出详细数据
    df.drop('year_month', axis=1).to_csv(csv_detail_path, index=False)
    print(f"详细数据已成功导出到：{csv_detail_path}")

    # 导出月度汇总数据
    pivot_table.to_csv(csv_summary_path, index=False)
    print(f"月度汇总数据已成功导出到：{csv_summary_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")