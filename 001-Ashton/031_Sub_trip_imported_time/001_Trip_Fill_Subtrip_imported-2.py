import pyodbc
import pandas as pd
import urllib
import os
from sqlalchemy import create_engine
from datetime import datetime

# 数据库连接参数
params = urllib.parse.quote_plus(
    'DRIVER={ODBC Driver 18 for SQL Server};SERVER=ashley-edw.database.windows.net;DATABASE=ASHLEY_EDW;Authentication=ActiveDirectoryIntegrated;Encrypt=yes;TrustServerCertificate=no;'
)

# 创建引擎
engine = create_engine('mssql+pyodbc:///?odbc_connect=' + params)

# 构建SQL查询
sql_parts = []
sql_parts.append('WITH WA AS (')
sql_parts.append('  SELECT *,')
sql_parts.append('    SUBSTRING(LEFT(t.transaction_string, 21), 12, 10) AS trip_nbr_2')
sql_parts.append('  FROM Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t')
sql_parts.append('  WHERE t.imported > DATEADD(DAY, -120, GETDATE())')
sql_parts.append('    AND t.transaction_string LIKE ' + chr(39) + 'L%' + chr(39))
sql_parts.append('    AND RIGHT(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10),2) <> ' + chr(39) + '00' + chr(39))
sql_parts.append('),')
sql_parts.append('sub_trip_imported AS (')
sql_parts.append('  SELECT *,')
sql_parts.append('    CAST(LEFT(trip_nbr_2, 7) AS INT) AS trip_nbr')
sql_parts.append('  FROM WA')
sql_parts.append('),')
sql_parts.append('tran_with_datetime AS (')
sql_parts.append('  SELECT')
sql_parts.append('    t1.tran_type,')
sql_parts.append('    t1.description,')
sql_parts.append('    t1.employee_id,')
sql_parts.append('    t1.control_number_2,')
sql_parts.append('    t1.start_tran_date,')
sql_parts.append('    CONVERT(VARCHAR(8), t1.start_tran_time, 108) AS start_tran_time,')
sql_parts.append('    t1.tran_qty,')
sql_parts.append(
    '    CAST(CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS DATETIME) AS start_tran_datetime')
sql_parts.append('  FROM Distribution_Warehouse_Wholesale.TranLog AS t1')
sql_parts.append('  WHERE t1.wh_id = ' + chr(39) + '335' + chr(39))
sql_parts.append('    AND t1.start_tran_date > DATEADD(DAY, -90, GETDATE())')
sql_parts.append('    AND t1.tran_type IN (' + chr(39) + '350' + chr(39) + ')')
sql_parts.append('),')
sql_parts.append('ranked_tran AS (')
sql_parts.append('  SELECT *,')
sql_parts.append('    ROW_NUMBER() OVER (')
sql_parts.append('      PARTITION BY tran_type, description, control_number_2')
sql_parts.append('      ORDER BY start_tran_datetime')
sql_parts.append('    ) AS rn')
sql_parts.append('  FROM tran_with_datetime')
sql_parts.append('),')
sql_parts.append('fill AS (')
sql_parts.append('  SELECT')
sql_parts.append('    tran_type,')
sql_parts.append('    description,')
sql_parts.append('    employee_id,')
sql_parts.append('    control_number_2,')
sql_parts.append('    start_tran_date,')
sql_parts.append('    start_tran_time,')
sql_parts.append('    start_tran_datetime,')
sql_parts.append('    tran_qty')
sql_parts.append('  FROM ranked_tran')
sql_parts.append('  WHERE rn = 1')
sql_parts.append(')')
sql_parts.append('SELECT t0.*,')
sql_parts.append('  DATEADD(HOUR, 13, b.imported) AS imported,')  # CST → UTC+7
sql_parts.append('  b.trip_nbr,')
sql_parts.append('  b.trip_nbr_2')
sql_parts.append('FROM fill AS t0')
sql_parts.append('LEFT JOIN sub_trip_imported AS b')
sql_parts.append('  ON CAST(LEFT(t0.control_number_2, 7) AS INT) = b.trip_nbr')
sql_parts.append('WHERE b.trip_nbr_2 IS NOT NULL')
sql_parts.append('ORDER BY b.trip_nbr_2')

# 连接所有SQL部分
query = ' '.join(sql_parts)

# 执行 SQL 并读取结果
df = pd.read_sql(query, engine)

# 添加时间差（小时）
df['time_diff_hours'] = (df['imported'] - df['start_tran_datetime']).dt.total_seconds() / 3600


# 分类区间标签
def time_bucket(hours):
    if pd.isna(hours):
        return 'Unknown'

    if hours < 0:
        return 'a. Negative'
    elif hours < 1:
        return 'b. 0-1 Hour'
    elif hours < 2:
        return 'c. 1-2 Hour'
    elif hours < 3:
        return 'd. 2-3 Hour'
    elif hours < 4:
        return 'e. 3-4 Hour'
    elif hours < 5:
        return 'f. 4-5 Hour'
    elif hours < 6:
        return 'g. 5-6 Hour'
    elif hours < 7:
        return 'h. 6-7 Hour'
    elif hours < 8:
        return 'i. 7-8 Hour'
    elif hours <= 12:
        return 'j. 8-12 Hour'
    elif hours <= 24:
        return 'k. 12-24 Hour'
    elif hours <= 48:  # 1-2 days
        return 'l. 1-2 days'
    elif hours <= 96:  # 2-4 days
        return 'm. 2-4 days'
    else:  # > 4 days
        return 'n. > 4 days'


df['time_diff_range'] = df['time_diff_hours'].apply(time_bucket)

# 输出结果
result = df
output_folder = os.path.expanduser('~/Downloads')
file_path = os.path.join(output_folder, 'result.csv')
result.to_csv(file_path, index=False)
print(f"结果已保存到 {file_path}")
