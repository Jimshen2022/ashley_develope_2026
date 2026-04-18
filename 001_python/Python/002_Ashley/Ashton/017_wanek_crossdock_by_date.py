import pyodbc
import pandas as pd
import os
import time
from datetime import datetime
import webbrowser

# 记录开始时间
start_time = time.time()

# 数据库连接信息
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'
connection_string = (
    f"DRIVER={{ODBC Driver 18 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"Authentication=ActiveDirectoryIntegrated;"  # 使用 Azure AD 集成验证
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
    f"Connection Timeout=120;"
)

# SQL 查询语句
query = """

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


        """

# 连接到数据库并执行查询
try:
    print("正在连接数据库...")
    with pyodbc.connect(connection_string) as conn:
        # 将查询结果加载到 pandas DataFrame
        print("正在执行查询...")
        df = pd.read_sql(query, conn)
        print(f"查询成功！获取到 {len(df)} 行数据。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()

# 显示数据预览
print("\n数据预览（前5行）:")
print(df.head(5).to_string())

# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
# output_path = os.path.join(output_dir, f"query_results_{current_time}.xlsx")
csv_path = os.path.join(output_dir, f"query_results_{current_time}.csv")
# html_path = os.path.join(output_dir, f"data_view_{current_time}.html")

# 导出到 Excel 文件
# try:
#     df.to_excel(output_path, index=False, engine='openpyxl')
#     print(f"数据已成功导出到 Excel 文件：{output_path}")
# except Exception as e:
#     print("导出 Excel 文件失败！", e)

# 导出到 CSV 文件
try:
    df.to_csv(csv_path, index=False)
    print(f"数据已成功导出到 CSV 文件：{csv_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)

# print(f"1. 打开Excel文件查看数据: {output_path}")

# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")

