# robust, retriable version
# tested pattern by Jim,Shen — Oct 2025

import os
import time
import urllib
import pandas as pd
from datetime import datetime
from sqlalchemy import create_engine, event
from sqlalchemy.exc import OperationalError, DBAPIError

# ---------- connection ----------
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'

params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
    "Login Timeout=30;"
    "Connection Timeout=30;"
    # 可选：若公司网络有丢包，可尝试：
    # "MARS_Connection=Yes;"
)

connection_string = f"mssql+pyodbc:///?odbc_connect={params}"

# 引擎设置：自动提交、心跳探活、定期回收
engine = create_engine(
    connection_string,
    connect_args={"autocommit": True},
    pool_pre_ping=True,     # 连接出池前先 ping
    pool_recycle=1800,      # 1800 秒后强制回收，避免网关闲置断链
    pool_size=5,
    max_overflow=2,
    future=True
)

# 设定 pyodbc 游标的查询超时（秒）
DEFAULT_QUERY_TIMEOUT = 600  # 10min
@event.listens_for(engine, "before_cursor_execute")
def _set_query_timeout(conn, cursor, statement, parameters, context, executemany):
    try:
        cursor.timeout = DEFAULT_QUERY_TIMEOUT
    except Exception:
        pass

# ---------- SQL ----------
query_detail = """
DECLARE @start_date date = '2025-01-01';
DECLARE @end_date   date = '2025-11-01';
DECLARE @tran_type  varchar(10) = '361';

WITH BaseDetail AS (
    SELECT 
        tl.wh_id,
        tl.routing_code,
        tl.control_number_2 as trip_nbr,
        -- 更稳妥的日期+时间拼接
        DATEADD(SECOND,
                DATEDIFF(SECOND, '00:00:00', CAST(tl.start_tran_time AS time(0))),
                CAST(tl.start_tran_date AS datetime2(0))) as dt,
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
),
Unioned AS (
    SELECT 
        wh_id,
        CAST(start_tran_date AS varchar(20)) as start_tran_date,
        [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11],
        [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23],
        CAST(0 AS int) AS sort_key
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
        AVG(CAST([23] AS decimal(10,2))),
        CAST(1 AS int) AS sort_key
    FROM PivotData
)
SELECT *
FROM Unioned
ORDER BY sort_key, wh_id, start_tran_date;
"""

# ---------- helper: retriable runner ----------
RETRY_ERRORS = ("08S01", "10060", "10054", "timed out", "Communication link failure")

def run_sql_with_retry(sql, engine, max_retries=3):
    attempt = 0
    while True:
        try:
            with engine.connect() as conn:
                return pd.read_sql(sql, conn)
        except (OperationalError, DBAPIError) as e:
            msg = str(e)
            transient = any(code in msg for code in RETRY_ERRORS)
            if transient and attempt < max_retries:
                delay = [1, 3, 7][attempt] if attempt < 3 else 10
                print(f"网络/超时异常，{delay}s 后重试（第 {attempt+1} 次）…\n{e}")
                time.sleep(delay)
                attempt += 1
                continue
            # 非瞬态或已达重试上限
            raise

# ---------- run ----------
start_time = time.time()

print("正在查询原始明细数据...")
df_detail = run_sql_with_retry(query_detail, engine)
print(f"原始明细数据查询成功！共 {len(df_detail)} 行。")

print("正在查询按小时透视数据...")
df_pivot = run_sql_with_retry(query_pivot, engine)
print(f"透视数据查询成功！共 {len(df_pivot)} 行。")

# 去掉排序辅助列
if "sort_key" in df_pivot.columns:
    df_pivot = df_pivot.drop(columns=["sort_key"])

# ---------- export ----------
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")

csv_detail_path = os.path.join(output_dir, f"wanek_trip_detail_{current_time}.csv")
csv_pivot_path = os.path.join(output_dir, f"wanek_trip_by_hour_pivot_{current_time}.csv")

df_detail.to_csv(csv_detail_path, index=False)
df_pivot.to_csv(csv_pivot_path, index=False)

print(f"\n原始明细数据已成功导出：\n{csv_detail_path}")
print(f"按小时透视数据已成功导出：\n{csv_pivot_path}")

# ---------- preview ----------
print("\n" + "="*80)
print("原始明细数据预览（前5行）：")
print("="*80)
print(df_detail.head())

print("\n" + "="*80)
print("按小时透视数据预览（前10行）：")
print("="*80)
print(df_pivot.head(10))

print(f"\n程序总运行时间：{time.time() - start_time:.2f} 秒")
