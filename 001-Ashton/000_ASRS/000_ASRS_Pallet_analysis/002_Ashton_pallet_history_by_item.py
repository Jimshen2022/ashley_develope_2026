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
        t.pick_put_id,
        t.unit_weight
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
        class_id, std_hand_qty, pallet_id, unit_volume, pick_put_id,unit_weight
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
      AND t.DateWeekEnding >= '2026-01-01'
    GROUP BY t.Warehouse, t.ItemNumber, t.DateWeekEnding
)
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
        when i.pallet_id = 16 then 'bulk'
        when i.pallet_id = 18 then '5x8'
    else 'Check' End as pallet_type,
    i.unit_volume,
    i.pick_put_id,
    i.unit_weight*0.453592 as [unit_weight(kg)],
    1.0* i.std_hand_qty * NULLIF(i.unit_weight, 0)*0.453592 AS [pallet_weight(kg)],
    a.[date],
    a.OnHandQty,
    -- 向上取整的托盘数（std_hand_qty 为 0/NULL 时返回 NULL）
    1.0 * a.OnHandQty / NULLIF(i.std_hand_qty, 0) AS pallets,
    1.0* a.OnHandQty * NULLIF(i.unit_volume, 0) AS cubes,
    1.0* a.OnHandQty * NULLIF(i.unit_weight, 0)*0.453592 AS [onhand_weight(kg)]
    -- 平均每托件数：当 total_qty=0 时给 0；否则用“总件数 ÷ 向上取整的托盘数”

FROM agg AS a
LEFT JOIN itm AS i 
  ON i.item_number = a.item_number
WHERE i.pick_put_id IN ('PALLT') 
    AND a.OnHandQty >0
ORDER BY a.[date], a.item_number;


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
csv_path = os.path.join(output_dir, f"001_Ashton_pallet_history_by_item_{current_time}.csv")
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


