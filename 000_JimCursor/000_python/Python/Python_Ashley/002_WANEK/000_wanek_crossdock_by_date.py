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

params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)

engine = create_engine('mssql+pyodbc:///?odbc_connect=' + params)

sql_query = '''
WITH mo AS (
    SELECT 
        t1.item_number, 
        t1.lot_number, 
        t1.control_number_2 as mo_nbr,
        MIN(t1.start_tran_date) as start_tran_date
    FROM [PowerBI_Distribution].[TranLog] AS t1 
    WHERE 
        t1.wh_id in ('35','34','31','33') 
        AND t1.tran_type IN ('111','114')
        AND t1.start_tran_date > DATEADD(DAY, -720, GETDATE())
    GROUP BY 
        t1.item_number, 
        t1.lot_number, 
        t1.control_number_2
),
trx AS (
    SELECT 
        MAX(t3.start_tran_date) AS start_tran_date,
        t3.wh_id,  
        t3.control_number_2 AS destination,
        t3.item_number,
        t3.control_number as order_nbr,
        t3.lot_number,
        mo.mo_nbr
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN mo 
        ON mo.item_number = t3.item_number 
        AND mo.lot_number = t3.lot_number
    WHERE 
        t3.wh_id in ('35','34','31','33') 
        AND t3.tran_type = '374'
        AND t3.start_tran_date > DATEADD(DAY, -21, GETDATE())
    GROUP BY
        t3.wh_id,  
        t3.control_number_2,
        t3.item_number,
        t3.control_number,
        t3.lot_number,
        mo.mo_nbr
)
SELECT  
    t.wh_id,
    t.destination,
    t.item_number,
    t.order_nbr,
    t.mo_nbr,
    COUNT(t.lot_number) as Qty,
    MAX(t.start_tran_date) as start_tran_date
FROM trx as t 
GROUP BY 
    t.wh_id,
    t.destination,
    t.item_number,
    t.order_nbr,
    t.mo_nbr
'''

# 查询数据
df = pd.read_sql(sql_query, engine)

df['start_tran_date'] = pd.to_datetime(df['start_tran_date']).dt.date
df['start_tran_date_str'] = df['start_tran_date'].astype(str)

pivot_df = df.pivot_table(
    index=['wh_id', 'destination', 'item_number', 'order_nbr', 'mo_nbr'],
    columns='start_tran_date_str',
    values='Qty',
    aggfunc='sum',
    fill_value=0
).reset_index()

# 确保日期列为整数
date_cols = [col for col in pivot_df.columns if col not in ['wh_id', 'destination', 'item_number', 'order_nbr', 'mo_nbr']]
for col in date_cols:
    pivot_df[col] = pivot_df[col].astype('int64')

dataset = pivot_df  # ← 必须叫 dataset
# print(dataset)

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
file_name = f'wanek_crossdock_query_{current_time}.csv'
file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

# 导出到 csv 文件
# output_path = os.path.expanduser("~/Downloads/query_results.xlsx")
try:
    dataset.to_csv(file_path, index=False)
    print(f"数据已成功导出到csv文件：{file_path}")
except Exception as e:
    print("导出 csv 文件失败！", e)

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")