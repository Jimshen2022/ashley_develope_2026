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
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)

# 创建引擎
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# SQL 查询语句 - 明细表
query_detail = """
DECLARE @YearStart DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);


WITH itm AS
(
    SELECT 
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
        ,CASE
            WHEN a.commodity_code NOT LIKE 'Z%' THEN 'CG'
            WHEN a.class_id IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG','FLOOROP','PAL5L','RUGS') THEN 'CG'
            WHEN a.class_id LIKE 'UPH%' THEN 'UPH'
            WHEN a.class_id IS NULL AND a.pick_put_id = 'UPH' THEN 'UPH'
            WHEN a.class_id IS NULL AND a.pick_put_id = 'PALLT' THEN 'CG'
            WHEN LEFT(a.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
            WHEN LEN(a.item_number) > 7 THEN 'CG'
            WHEN LEFT(a.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            ELSE 'CG'
        END AS product
    FROM Distribution_Warehouse_Wholesale.t_item_master AS a
    WHERE a.wh_id = '335'
),
stock_data AS (
        SELECT t0.Warehouse,                       
               t0.DateWeekEnding,
               t0.ItemNumber,
               CASE 
                   WHEN itm.product IS NOT NULL THEN itm.product
                   WHEN LEFT(t0.ItemNumber, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
                   ELSE 'CG'
               END AS product,
               itm.unit_volume,
               Sum(t0.OnHandQty) as OnHandQty,
               Sum(t0.OnHandQty)*itm.unit_volume as OnHandCubes
        FROM Inventory_Enh_History.ItemBalance AS t0 
        LEFT JOIN itm AS itm ON t0.ItemNumber = itm.item_number
        WHERE t0.Warehouse = '335' 
          AND t0.DateWeekEnding >= @YearStart
        GROUP BY t0.Warehouse, 
                 t0.DateWeekEnding,
                 t0.ItemNumber, 
                 CASE 
                     WHEN itm.product IS NOT NULL THEN itm.product
                     WHEN LEFT(t0.ItemNumber, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
                     ELSE 'CG'
                 END,
                 itm.unit_volume
)
SELECT 
    t1.PTLITNBR,
    itm.product,
    itm.description,
    t1.PTLWHSE,
    t1.PTLDATATYPE,
    t1.SnapShotDate AS SnapShotDateTime,
    CAST(t1.SnapShotDate AS date) AS SnapShotDate,
    SUM(t1.PTLWEEK1) AS SafetyStockQty,
    SUM(ISNULL(sd.OnHandQty, 0)) AS OnHandQty,

    -- 计算 Fulfillment Rate，上限为 100%
    CASE 
        WHEN SUM(t1.PTLWEEK1) > 0 THEN 
            CASE 
                WHEN CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / SUM(t1.PTLWEEK1) * 100 > 100 
                THEN 100.00
                ELSE CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / SUM(t1.PTLWEEK1) * 100
            END
        ELSE NULL 
    END AS FulfillmentRate_Pct,

    -- 判断是否满足 Safety Stock
    CASE 
        WHEN SUM(ISNULL(sd.OnHandQty, 0)) >= SUM(t1.PTLWEEK1) THEN 'Met'
        ELSE 'Not Met'
    END AS SafetyStockStatus,

    -- 缺口数量
    CASE 
        WHEN SUM(t1.PTLWEEK1) - SUM(ISNULL(sd.OnHandQty, 0)) > 0 
        THEN SUM(t1.PTLWEEK1) - SUM(ISNULL(sd.OnHandQty, 0))
        ELSE 0
    END AS ShortfallQty

FROM SupplyChain_Enh.PlanDetailTimelineSnapshot AS t1 WITH (NOLOCK)
LEFT JOIN stock_data AS sd 
    ON t1.PTLITNBR = sd.ItemNumber 
    AND sd.DateWeekEnding = CAST(t1.SnapShotDate AS date)
LEFT JOIN itm AS itm 
    ON t1.PTLITNBR = itm.item_number
WHERE t1.PTLDATATYPE = 'SAFETY STK' 
  AND t1.PTLWHSE = '335'
  AND t1.PTLWEEK1 > 0
  AND t1.SnapShotDate >= @YearStart
  AND DATEPART(WEEKDAY, t1.SnapShotDate) = 7
GROUP BY 
    t1.PTLITNBR,
    itm.product,
    itm.description,
    t1.PTLWHSE,
    t1.PTLDATATYPE,
    t1.SnapShotDate
ORDER BY t1.SnapShotDate DESC;
"""

# SQL 查询语句 - 汇总表（按日期，计算每个产品的平均履约率，保持百分比格式）
query_summary = """
DECLARE @YearStart DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);

WITH itm AS
(
    SELECT 
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
        ,CASE
            WHEN a.commodity_code NOT LIKE 'Z%' THEN 'CG'
            WHEN a.class_id IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG','FLOOROP','PAL5L','RUGS') THEN 'CG'
            WHEN a.class_id LIKE 'UPH%' THEN 'UPH'
            WHEN a.class_id IS NULL AND a.pick_put_id = 'UPH' THEN 'UPH'
            WHEN a.class_id IS NULL AND a.pick_put_id = 'PALLT' THEN 'CG'
            WHEN LEFT(a.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
            WHEN LEN(a.item_number) > 7 THEN 'CG'
            WHEN LEFT(a.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            ELSE 'CG'
        END AS product
    FROM Distribution_Warehouse_Wholesale.t_item_master AS a
    WHERE a.wh_id = '335'
),
stock_data AS (
        SELECT t0.Warehouse,                       
               t0.DateWeekEnding,
               t0.ItemNumber,
               CASE 
                   WHEN itm.product IS NOT NULL THEN itm.product
                   WHEN LEFT(t0.ItemNumber, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
                   ELSE 'CG'
               END AS product,
               itm.unit_volume,
               Sum(t0.OnHandQty) as OnHandQty,
               Sum(t0.OnHandQty)*itm.unit_volume as OnHandCubes
        FROM Inventory_Enh_History.ItemBalance AS t0 
        LEFT JOIN itm AS itm ON t0.ItemNumber = itm.item_number
        WHERE t0.Warehouse = '335' 
          AND t0.DateWeekEnding >= @YearStart
        GROUP BY t0.Warehouse, 
                 t0.DateWeekEnding,
                 t0.ItemNumber, 
                 CASE 
                     WHEN itm.product IS NOT NULL THEN itm.product
                     WHEN LEFT(t0.ItemNumber, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
                     ELSE 'CG'
                 END,
                 itm.unit_volume
),
detail_results AS (
    SELECT 
        t1.PTLITNBR,
        itm.product,
        CAST(t1.SnapShotDate AS date) AS SnapShotDate,
        SUM(t1.PTLWEEK1) AS SafetyStockQty,
        SUM(ISNULL(sd.OnHandQty, 0)) AS OnHandQty,

        -- 每个 item 的履约率（上限100%）
        CASE 
            WHEN SUM(t1.PTLWEEK1) > 0 THEN 
                CASE 
                    WHEN CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / SUM(t1.PTLWEEK1) * 100 > 100 
                    THEN 100.00
                    ELSE CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / SUM(t1.PTLWEEK1) * 100
                END
            ELSE NULL 
        END AS FulfillmentRate_Pct

    FROM SupplyChain_Enh.PlanDetailTimelineSnapshot AS t1 WITH (NOLOCK)
    LEFT JOIN stock_data AS sd 
        ON t1.PTLITNBR = sd.ItemNumber 
        AND sd.DateWeekEnding = CAST(t1.SnapShotDate AS date)
    LEFT JOIN itm AS itm 
        ON t1.PTLITNBR = itm.item_number
    WHERE t1.PTLDATATYPE = 'SAFETY STK' 
      AND t1.PTLWHSE = '335'
      AND t1.PTLWEEK1 > 0
      AND t1.SnapShotDate >= @YearStart
      AND DATEPART(WEEKDAY, t1.SnapShotDate) = 7
    GROUP BY 
        t1.PTLITNBR,
        itm.product,
        CAST(t1.SnapShotDate AS date)
)
SELECT 
    SnapShotDate,

    -- CG 的平均履约率（百分比格式）
    CAST(AVG(CASE WHEN product = 'CG' THEN FulfillmentRate_Pct ELSE NULL END) AS DECIMAL(10,2)) AS CG_Rate,

    -- UPH 的平均履约率（百分比格式）
    CAST(AVG(CASE WHEN product = 'UPH' THEN FulfillmentRate_Pct ELSE NULL END) AS DECIMAL(10,2)) AS UPH_Rate

FROM detail_results
WHERE FulfillmentRate_Pct IS NOT NULL
GROUP BY SnapShotDate
ORDER BY SnapShotDate DESC;
"""

# 执行明细查询
print("正在执行明细查询...")
try:
    df_detail = pd.read_sql(query_detail, engine)
    print(f"明细查询成功！共加载 {len(df_detail)} 行数据。")
except Exception as e:
    print("明细查询失败！", e)
    exit()

# 执行汇总查询
print("正在执行汇总查询...")
try:
    df_summary = pd.read_sql(query_summary, engine)
    print(f"汇总查询成功！共加载 {len(df_summary)} 行数据。")
except Exception as e:
    print("汇总查询失败！", e)
    exit()

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
csv_detail_path = os.path.join(output_dir, f"SafetyStock_Detail_{current_time}.csv")
csv_summary_path = os.path.join(output_dir, f"SafetyStock_Summary_{current_time}.csv")

# 导出明细表到 CSV 文件
try:
    df_detail.to_csv(csv_detail_path, index=False)
    print(f"明细数据已成功导出到 CSV 文件：{csv_detail_path}")
except Exception as e:
    print("导出明细 CSV 文件失败！", e)

# 导出汇总表到 CSV 文件
try:
    df_summary.to_csv(csv_summary_path, index=False)
    print(f"汇总数据已成功导出到 CSV 文件：{csv_summary_path}")
except Exception as e:
    print("导出汇总 CSV 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")

# 显示数据预览
print("\n=== 明细数据预览 (前5行) ===")
print(df_detail.head())
print(f"\n明细表形状: {df_detail.shape}")

print("\n=== 汇总数据预览 ===")
print(df_summary)
print(f"\n汇总表形状: {df_summary.shape}")