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
        WITH item_master_info AS (SELECT t1.ITNBR, \
                                         CASE WHEN t2.PICKPUT = 'UPH' THEN 'UPH' ELSE 'CG' END AS product_category \
                                  FROM MasterData_ItemMaster_AFI.ITMRVA AS t1 \
                                           LEFT JOIN MasterData_ItemMaster_AFI.ITBEXT AS t2 \
                                                     ON t2.ITNBR = t1.ITNBR AND t2.HOUSE = t1.STID \
                                  WHERE t1.STID = '335'),
             base_data AS (SELECT CAST(start_tran_date AS DATE)   AS tran_date, \
                                  DATEPART(HOUR, start_tran_time) AS tran_hour, \
                                  item_number, \
                                  SUM(tran_qty)                   AS picked_qty \
                           FROM Distribution_Warehouse_Wholesale.TranLog \
                           WHERE tran_type LIKE '363' \
                             AND start_tran_date >= '2025-06-01' \
                             AND wh_id = '335' \
                           GROUP BY CAST(start_tran_date AS DATE), \
                                    DATEPART(HOUR, start_tran_time), \
                                    item_number),
             item_first_appearance AS (SELECT tran_date, \
                                              item_number, \
                                              MIN(tran_hour)                                                AS first_hour_1h, \
                                              MIN(CASE WHEN tran_hour BETWEEN 0 AND 1 THEN tran_hour END)   AS first_in_0_1, \
                                              MIN(CASE WHEN tran_hour BETWEEN 2 AND 3 THEN tran_hour END)   AS first_in_2_3, \
                                              MIN(CASE WHEN tran_hour BETWEEN 4 AND 5 THEN tran_hour END)   AS first_in_4_5, \
                                              MIN(CASE WHEN tran_hour BETWEEN 6 AND 7 THEN tran_hour END)   AS first_in_6_7, \
                                              MIN(CASE WHEN tran_hour BETWEEN 8 AND 9 THEN tran_hour END)   AS first_in_8_9, \
                                              MIN(CASE WHEN tran_hour BETWEEN 10 AND 11 THEN tran_hour END) AS first_in_10_11, \
                                              MIN(CASE WHEN tran_hour BETWEEN 12 AND 13 THEN tran_hour END) AS first_in_12_13, \
                                              MIN(CASE WHEN tran_hour BETWEEN 14 AND 15 THEN tran_hour END) AS first_in_14_15, \
                                              MIN(CASE WHEN tran_hour BETWEEN 16 AND 17 THEN tran_hour END) AS first_in_16_17, \
                                              MIN(CASE WHEN tran_hour BETWEEN 18 AND 19 THEN tran_hour END) AS first_in_18_19, \
                                              MIN(CASE WHEN tran_hour BETWEEN 20 AND 21 THEN tran_hour END) AS first_in_20_21, \
                                              MIN(CASE WHEN tran_hour BETWEEN 22 AND 23 THEN tran_hour END) AS first_in_22_23, \
                                              MIN(CASE WHEN tran_hour BETWEEN 0 AND 2 THEN tran_hour END)   AS first_in_0_2, \
                                              MIN(CASE WHEN tran_hour BETWEEN 3 AND 5 THEN tran_hour END)   AS first_in_3_5, \
                                              MIN(CASE WHEN tran_hour BETWEEN 6 AND 8 THEN tran_hour END)   AS first_in_6_8, \
                                              MIN(CASE WHEN tran_hour BETWEEN 9 AND 11 THEN tran_hour END)  AS first_in_9_11, \
                                              MIN(CASE WHEN tran_hour BETWEEN 12 AND 14 THEN tran_hour END) AS first_in_12_14, \
                                              MIN(CASE WHEN tran_hour BETWEEN 15 AND 17 THEN tran_hour END) AS first_in_15_17, \
                                              MIN(CASE WHEN tran_hour BETWEEN 18 AND 20 THEN tran_hour END) AS first_in_18_20, \
                                              MIN(CASE WHEN tran_hour BETWEEN 21 AND 23 THEN tran_hour END) AS first_in_21_23, \
                                              MIN(CASE WHEN tran_hour BETWEEN 0 AND 3 THEN tran_hour END)   AS first_in_0_3, \
                                              MIN(CASE WHEN tran_hour BETWEEN 4 AND 7 THEN tran_hour END)   AS first_in_4_7, \
                                              MIN(CASE WHEN tran_hour BETWEEN 8 AND 11 THEN tran_hour END)  AS first_in_8_11, \
                                              MIN(CASE WHEN tran_hour BETWEEN 12 AND 15 THEN tran_hour END) AS first_in_12_15, \
                                              MIN(CASE WHEN tran_hour BETWEEN 16 AND 19 THEN tran_hour END) AS first_in_16_19, \
                                              MIN(CASE WHEN tran_hour BETWEEN 20 AND 23 THEN tran_hour END) AS first_in_20_23 \
                                       FROM base_data \
                                       GROUP BY tran_date, item_number)
        SELECT b.tran_date, \
               b.tran_hour, \
               b.item_number, \
               im.product_category, \
               1       AS sku_count_by_hour, \
               CASE \
                   WHEN (b.tran_hour BETWEEN 0 AND 1 AND b.tran_hour = fa.first_in_0_1) OR \
                        (b.tran_hour BETWEEN 2 AND 3 AND b.tran_hour = fa.first_in_2_3) OR \
                        (b.tran_hour BETWEEN 4 AND 5 AND b.tran_hour = fa.first_in_4_5) OR \
                        (b.tran_hour BETWEEN 6 AND 7 AND b.tran_hour = fa.first_in_6_7) OR \
                        (b.tran_hour BETWEEN 8 AND 9 AND b.tran_hour = fa.first_in_8_9) OR \
                        (b.tran_hour BETWEEN 10 AND 11 AND b.tran_hour = fa.first_in_10_11) OR \
                        (b.tran_hour BETWEEN 12 AND 13 AND b.tran_hour = fa.first_in_12_13) OR \
                        (b.tran_hour BETWEEN 14 AND 15 AND b.tran_hour = fa.first_in_14_15) OR \
                        (b.tran_hour BETWEEN 16 AND 17 AND b.tran_hour = fa.first_in_16_17) OR \
                        (b.tran_hour BETWEEN 18 AND 19 AND b.tran_hour = fa.first_in_18_19) OR \
                        (b.tran_hour BETWEEN 20 AND 21 AND b.tran_hour = fa.first_in_20_21) OR \
                        (b.tran_hour BETWEEN 22 AND 23 AND b.tran_hour = fa.first_in_22_23) \
                       THEN 1 \
                   ELSE 0 \
                   END AS sku_count_2h, \
               CASE \
                   WHEN (b.tran_hour BETWEEN 0 AND 2 AND b.tran_hour = fa.first_in_0_2) OR \
                        (b.tran_hour BETWEEN 3 AND 5 AND b.tran_hour = fa.first_in_3_5) OR \
                        (b.tran_hour BETWEEN 6 AND 8 AND b.tran_hour = fa.first_in_6_8) OR \
                        (b.tran_hour BETWEEN 9 AND 11 AND b.tran_hour = fa.first_in_9_11) OR \
                        (b.tran_hour BETWEEN 12 AND 14 AND b.tran_hour = fa.first_in_12_14) OR \
                        (b.tran_hour BETWEEN 15 AND 17 AND b.tran_hour = fa.first_in_15_17) OR \
                        (b.tran_hour BETWEEN 18 AND 20 AND b.tran_hour = fa.first_in_18_20) OR \
                        (b.tran_hour BETWEEN 21 AND 23 AND b.tran_hour = fa.first_in_21_23) \
                       THEN 1 \
                   ELSE 0 \
                   END AS sku_count_3h, \
               CASE \
                   WHEN (b.tran_hour BETWEEN 0 AND 3 AND b.tran_hour = fa.first_in_0_3) OR \
                        (b.tran_hour BETWEEN 4 AND 7 AND b.tran_hour = fa.first_in_4_7) OR \
                        (b.tran_hour BETWEEN 8 AND 11 AND b.tran_hour = fa.first_in_8_11) OR \
                        (b.tran_hour BETWEEN 12 AND 15 AND b.tran_hour = fa.first_in_12_15) OR \
                        (b.tran_hour BETWEEN 16 AND 19 AND b.tran_hour = fa.first_in_16_19) OR \
                        (b.tran_hour BETWEEN 20 AND 23 AND b.tran_hour = fa.first_in_20_23) \
                       THEN 1 \
                   ELSE 0 \
                   END AS sku_count_4h, \
               b.picked_qty
        FROM base_data b
                 LEFT JOIN item_first_appearance fa
                           ON b.tran_date = fa.tran_date AND b.item_number = fa.item_number
                 LEFT JOIN item_master_info im
                           ON b.item_number = im.ITNBR
        ORDER BY b.tran_date, \
                 b.tran_hour, \
                 b.item_number \
        """

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("行数:", len(df))
    print("查询成功！数据已加载到 DataFrame。")
    print("\n前10行数据预览：")
    print(df.head(10))
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 确保 tran_date 是 datetime 类型
df['tran_date'] = pd.to_datetime(df['tran_date'])

# 按日期和小时汇总统计
summary_by_date_hour = df.groupby(['tran_date', 'tran_hour', 'product_category']).agg({
    'item_number': 'nunique',
    'sku_count_by_hour': 'sum',
    'sku_count_2h': 'sum',
    'sku_count_3h': 'sum',
    'sku_count_4h': 'sum',
    'picked_qty': 'sum'
}).reset_index()

summary_by_date_hour.columns = [
    'tran_date', 'tran_hour', 'product_category', 'unique_sku_count',
    'first_time_1h', 'first_time_2h', 'first_time_3h', 'first_time_4h',
    'total_picked_qty'
]

print("\n按日期、小时和产品类别汇总统计：")
print(summary_by_date_hour.head(20))

# 导出到 Excel 文件
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
filename = f"picking_analysis_{timestamp}.xlsx"
output_path = os.path.expanduser(f"~/Downloads/{filename}")

try:
    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='明细数据', index=False)
        summary_by_date_hour.to_excel(writer, sheet_name='按日期小时类别汇总', index=False)

    print(f"\n数据已成功导出到 Excel 文件：{output_path}")
    print(f"- 工作表1: 明细数据 ({len(df)} 行)")
    print(f"- 工作表2: 按日期小时类别汇总 ({len(summary_by_date_hour)} 行)")
except Exception as e:
    print("导出 Excel 文件失败！", e)

# 运行时长
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")