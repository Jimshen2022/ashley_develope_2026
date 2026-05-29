# this file is tested and works well by Jim,Shen on Mar.08.2025
# Updated: fix SQL trailing comma bug, rename output CSV, add summary export
# Updated: add pallet_weight_bucket column to detail & summary
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

# ============================================================
# SQL 查询1：明细数据（detail）
# ============================================================
query_detail = """

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
        class_id, std_hand_qty, pallet_id, unit_volume, pick_put_id, unit_weight
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
    CASE
        WHEN i.pallet_id = 1  THEN '5x5'
        WHEN i.pallet_id = 3  THEN '5x7'
        WHEN i.pallet_id = 4  THEN '3.5x5'
        WHEN i.pallet_id = 5  THEN '3.5x7'
        WHEN i.pallet_id = 16 THEN 'bulk'
        WHEN i.pallet_id = 18 THEN '5x8'
        ELSE 'Check'
    END AS pallet_type,
    i.unit_volume,
    i.pick_put_id,
    i.unit_weight * 0.453592                                    AS [unit_weight(kg)],
    1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 AS [pallet_weight(kg)],
    a.[date],
    a.OnHandQty,
    1.0 * a.OnHandQty / NULLIF(i.std_hand_qty, 0)              AS pallets,
    1.0 * a.OnHandQty * NULLIF(i.unit_volume, 0)                AS cubes,
    1.0 * a.OnHandQty * NULLIF(i.unit_weight, 0) * 0.453592     AS [onhand_weight(kg)],
    CASE
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  500  THEN '0~500kg'
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  1000 THEN '500~1000kg'
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  1500 THEN '1000~1500kg'
        WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 >= 1500 THEN 'Over 1500kg'
        ELSE NULL
    END AS pallet_weight_bucket
FROM agg AS a
LEFT JOIN itm AS i
    ON i.item_number = a.item_number
WHERE i.pick_put_id IN ('PALLT')
    AND a.OnHandQty > 0
ORDER BY a.[date], a.item_number;

"""

# ============================================================
# SQL 查询2：汇总数据（summary）—— 按 pallet_type + pallet_weight_bucket + date 聚合
# 输出列：pallet_type, pallet_weight_bucket, date, OnHandQty, cubes, pallets,
#         avg_piece_per_pallet, unique_sku_count,
#         avg_cubes_per_pallet, avg_weight(kg)_per_pallet
# ============================================================
query_summary = """

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
        class_id, std_hand_qty, pallet_id, unit_volume, pick_put_id, unit_weight
    FROM ranked
    WHERE rn = 1
),
agg AS (
    SELECT 
        t.Warehouse AS wh_id,
        t.ItemNumber AS item_number,
        t.DateWeekEnding AS [date],
        SUM(t.OnHandQty) AS OnHandQty
    FROM Inventory_Enh_History.ItemBalance AS t
    WHERE t.Warehouse = '335'
      AND t.DateWeekEnding >= '2026-01-01'
    GROUP BY t.Warehouse, t.ItemNumber, t.DateWeekEnding
),
detail AS (
    SELECT 
        a.wh_id,
        a.item_number,
        i.std_hand_qty,
        CASE 
            WHEN i.pallet_id = 1  THEN '5x5'
            WHEN i.pallet_id = 3  THEN '5x7'
            WHEN i.pallet_id = 4  THEN '3.5x5'
            WHEN i.pallet_id = 5  THEN '3.5x7'
            WHEN i.pallet_id = 16 THEN 'bulk'
            WHEN i.pallet_id = 18 THEN '5x8'
            ELSE 'Check'
        END AS pallet_type,
        CASE
            WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  500  THEN '0~500kg'
            WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  1000 THEN '500~1000kg'
            WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 <  1500 THEN '1000~1500kg'
            WHEN 1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 >= 1500 THEN 'Over 1500kg'
            ELSE NULL
        END AS pallet_weight_bucket,
        i.unit_volume,
        i.unit_weight * 0.453592                                    AS unit_weight_kg,
        1.0 * i.std_hand_qty * NULLIF(i.unit_weight, 0) * 0.453592 AS pallet_weight_kg,
        a.[date],
        a.OnHandQty,
        1.0 * a.OnHandQty / NULLIF(i.std_hand_qty, 0)              AS pallets,
        1.0 * a.OnHandQty * NULLIF(i.unit_volume, 0)                AS cubes,
        1.0 * a.OnHandQty * NULLIF(i.unit_weight, 0) * 0.453592     AS onhand_weight_kg
    FROM agg AS a
    LEFT JOIN itm AS i 
        ON i.item_number = a.item_number
    WHERE i.pick_put_id IN ('PALLT') 
        AND a.OnHandQty > 0
)
SELECT
    pallet_type,
    [date],
    SUM(OnHandQty)                                              AS OnHandQty,
    SUM(cubes)                                                  AS cubes,
    SUM(pallets)                                                AS pallets,
    1.0 * SUM(OnHandQty) / NULLIF(SUM(pallets), 0)             AS avg_piece_per_pallet,
    COUNT(DISTINCT item_number)                                 AS unique_sku_count,
    1.0 * SUM(cubes)   / NULLIF(SUM(pallets), 0)               AS avg_cubes_per_pallet,
    1.0 * SUM(cubes)   / NULLIF(SUM(OnHandQty), 0)             AS avg_cubes_per_piece,
    1.0 * SUM(onhand_weight_kg) / NULLIF(SUM(pallets), 0)      AS [avg_weight(kg)_per_pallet]
FROM detail
GROUP BY
    pallet_type,
    [date]
ORDER BY
    pallet_type,
    [date];

"""

# ============================================================
# 执行查询
# ============================================================
try:
    df_detail = pd.read_sql(query_detail, engine)
    print(f"明细查询成功！共 {len(df_detail):,} 行数据。")
except Exception as e:
    print("明细查询失败！", e)
    exit()

try:
    df_summary = pd.read_sql(query_summary, engine)
    print(f"汇总查询成功！共 {len(df_summary):,} 行数据。")
except Exception as e:
    print("汇总查询失败！", e)
    exit()

# ============================================================
# 生成文件路径
# ============================================================
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")

csv_detail_path  = os.path.join(output_dir, f"001_ashton_history_inv_by_pallets_{current_time}.csv")
csv_summary_path = os.path.join(output_dir, f"001_ashton_history_inv_by_pallets_summary_{current_time}.csv")

# ============================================================
# 导出到 CSV
# ============================================================
try:
    df_detail.to_csv(csv_detail_path, index=False)
    print(f"明细数据已导出：{csv_detail_path}")
except Exception as e:
    print("导出明细 CSV 失败！", e)

try:
    df_summary.to_csv(csv_summary_path, index=False)
    print(f"汇总数据已导出：{csv_summary_path}")
except Exception as e:
    print("导出汇总 CSV 失败！", e)

# ============================================================
# 打印运行时间
# ============================================================
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")