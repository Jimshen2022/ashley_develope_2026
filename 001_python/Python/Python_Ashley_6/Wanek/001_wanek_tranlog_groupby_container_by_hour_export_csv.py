# this file is tested and works well by Jim,Shen on Mar.08.2025
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
def get_connection_string():
    params = urllib.parse.quote_plus(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Authentication=ActiveDirectoryIntegrated;"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
    )
    return f"mssql+pyodbc:///?odbc_connect={params}"


# SQL 查询语句 - 原始明细表
query_detail = """
DECLARE @start_date date = '2025-01-01';
DECLARE @end_date   date = '2025-11-01';
DECLARE @tran_type  varchar(10) = '361';

WITH BaseDetail AS (
    SELECT 
        tl.wh_id,
        tl.routing_code,
        tl.control_number_2 as trip_nbr,
        CAST(tl.start_tran_date AS datetime) + CAST(tl.start_tran_time AS datetime) as dt,
        CAST(tl.start_tran_date AS date) as start_tran_date,
        DATEPART(HOUR, tl.start_tran_time) as trip_hour,
        tl.tran_qty,
        tl.item_number
    FROM Distribution_Warehouse_Wholesale.TranLog AS tl
    WHERE tl.start_tran_date >= @start_date
      AND tl.start_tran_date <  @end_date
      AND tl.wh_id IN ('31', '33', '34', '35')
      AND tl.tran_type = @tran_type
)
SELECT 
    wh_id,
    routing_code,
    trip_nbr,
    MAX(dt) as dt,
    SUM(tran_qty) AS trip_qty,
    COUNT(DISTINCT item_number) AS sku_count
FROM BaseDetail
GROUP BY 
    wh_id,
    routing_code,
    trip_nbr
ORDER BY wh_id, dt;
"""

# SQL 查询语句 - 按小时透视表
query_pivot = """
DECLARE @start_date date = '2025-01-01';
DECLARE @end_date   date = '2025-11-01';
DECLARE @tran_type  varchar(10) = '361';

WITH BaseDetail AS (
    SELECT 
        tl.wh_id,
        tl.routing_code,
        tl.control_number_2 as trip_nbr,
        CAST(tl.start_tran_date AS date) as start_tran_date,
        DATEPART(HOUR, tl.start_tran_time) as trip_hour
    FROM Distribution_Warehouse_Wholesale.TranLog AS tl
    WHERE tl.start_tran_date >= @start_date
      AND tl.start_tran_date <  @end_date
      AND tl.wh_id IN ('31', '33', '34', '35')
      AND tl.tran_type = @tran_type
),
PivotData AS (
    SELECT 
        wh_id,
        start_tran_date,
        [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11],
        [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23]
    FROM (
        SELECT DISTINCT
            wh_id,
            start_tran_date,
            trip_hour,
            trip_nbr
        FROM BaseDetail
    ) AS SourceTable
    PIVOT (
        COUNT(trip_nbr)
        FOR trip_hour IN (
            [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11],
            [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23]
        )
    ) AS PivotTable
)
SELECT 
    wh_id,
    CAST(start_tran_date AS varchar(20)) as start_tran_date,
    [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11],
    [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23]
FROM PivotData

UNION ALL

SELECT 
    'AVG' as wh_id,
    'Average' as start_tran_date,
    AVG(CAST([0] AS decimal(10,2))),
    AVG(CAST([1] AS decimal(10,2))),
    AVG(CAST([2] AS decimal(10,2))),
    AVG(CAST([3] AS decimal(10,2))),
    AVG(CAST([4] AS decimal(10,2))),
    AVG(CAST([5] AS decimal(10,2))),
    AVG(CAST([6] AS decimal(10,2))),
    AVG(CAST([7] AS decimal(10,2))),
    AVG(CAST([8] AS decimal(10,2))),
    AVG(CAST([9] AS decimal(10,2))),
    AVG(CAST([10] AS decimal(10,2))),
    AVG(CAST([11] AS decimal(10,2))),
    AVG(CAST([12] AS decimal(10,2))),
    AVG(CAST([13] AS decimal(10,2))),
    AVG(CAST([14] AS decimal(10,2))),
    AVG(CAST([15] AS decimal(10,2))),
    AVG(CAST([16] AS decimal(10,2))),
    AVG(CAST([17] AS decimal(10,2))),
    AVG(CAST([18] AS decimal(10,2))),
    AVG(CAST([19] AS decimal(10,2))),
    AVG(CAST([20] AS decimal(10,2))),
    AVG(CAST([21] AS decimal(10,2))),
    AVG(CAST([22] AS decimal(10,2))),
    AVG(CAST([23] AS decimal(10,2)))
FROM PivotData

ORDER BY 
    CASE WHEN wh_id = 'AVG' THEN 'ZZZZ' ELSE wh_id END,
    start_tran_date;
"""

# 执行查询 - 原始明细表
print("正在查询原始明细数据...")
try:
    engine1 = create_engine(get_connection_string(), poolclass=None)
    df_detail = pd.read_sql(query_detail, engine1)
    engine1.dispose()
    del engine1
    print(f"原始明细数据查询成功！共 {len(df_detail)} 行。")
except Exception as e:
    print("原始明细数据查询失败！", e)
    import traceback

    traceback.print_exc()
    exit()

# 等待一秒，确保连接完全释放
time.sleep(1)

# 执行查询 - 透视表
print("正在查询按小时透视数据...")
try:
    engine2 = create_engine(get_connection_string(), poolclass=None)
    df_pivot = pd.read_sql(query_pivot, engine2)
    engine2.dispose()
    del engine2
    print(f"透视数据查询成功！共 {len(df_pivot)} 行。")
except Exception as e:
    print("透视数据查询失败！", e)
    import traceback

    traceback.print_exc()
    exit()

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
excel_path = os.path.join(output_dir, f"wanek_trip_analysis_{current_time}.xlsx")

# 导出到 Excel 文件的两个工作表
print("\n正在导出到 Excel 文件...")
try:
    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        # 写入原始明细表到第一个工作表
        df_detail.to_excel(writer, sheet_name='Trip Detail', index=False)

        # 写入透视表到第二个工作表
        df_pivot.to_excel(writer, sheet_name='Hourly Pivot', index=False)

        # 自动调整列宽（可选）
        for sheet_name in writer.sheets:
            worksheet = writer.sheets[sheet_name]
            for column in worksheet.columns:
                max_length = 0
                column_letter = column[0].column_letter
                for cell in column:
                    try:
                        if len(str(cell.value)) > max_length:
                            max_length = len(str(cell.value))
                    except:
                        pass
                adjusted_width = min(max_length + 2, 50)
                worksheet.column_dimensions[column_letter].width = adjusted_width

    print(f"\n✅ 数据已成功导出到 Excel 文件：")
    print(f"   {excel_path}")
    print(f"\n包含两个工作表：")
    print(f"   1. 'Trip Detail' - 原始明细数据 ({len(df_detail)} 行)")
    print(f"   2. 'Hourly Pivot' - 按小时透视数据 ({len(df_pivot)} 行)")

except Exception as e:
    print("导出 Excel 文件失败！", e)
    import traceback

    traceback.print_exc()
    exit()

# 打印数据预览
print("\n" + "=" * 80)
print("原始明细数据预览（前5行）：")
print("=" * 80)
print(df_detail.head())

print("\n" + "=" * 80)
print("按小时透视数据预览（前10行）：")
print("=" * 80)
print(df_pivot.head(10))

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")