import pyodbc
import pandas as pd
import datetime
import os
import time

# 记录开始时间
start_time = time.time()

# 数据库连接信息 (EDW - Azure SQL Database)
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'
connection_string = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"Authentication=ActiveDirectoryIntegrated;"  # 使用 Azure AD 集成验证
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
    f"Connection Timeout=120;"
)

# SQL 查询语句
sql_query = """
/*
serial_no_status
L -- loaded
R -- InWarehouse
S -- Shipped
H -- Hold
O -- orphaned

master status
L -- loaded
R -- InWarehouse
S -- Shipped
H -- Hold

select top 10 *
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
where t1.wh_id = '335'
*/

declare @start_date date = '2022-01-01';
declare @end_date date = getdate();

with trx as (
select 
    t2.item_number,
    t2.tran_type,
    t2.start_tran_date,
    t2.lot_number,
    t2.control_number_2,
    t2.routing_code,
    t2.wh_id AS tranlog_wh_id
from Distribution_Warehouse_Wholesale.TranLog as t2 
where t2.wh_id = '335' 
    and t2.tran_type = '347' 
    and t2.start_tran_date >= @start_date
    and t2.start_tran_date <=  @end_date
),
sn as (
    SELECT t1.wh_id, 
    t1.serial_number, 
    t1.item_number, 
    t1.serial_no_status, 
    t1.master_status, 
    t1.location_id, 
    CAST(t1.received_date AS DATE) AS received_date
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
    WHERE t1.wh_id = '335'
    AND t1.serial_no_status != 'O'
    AND t1.master_status != 'S'
)
SELECT t1.*, t2.start_tran_date, t2.tran_type, t2.control_number_2, t2.routing_code, t2.tranlog_wh_id
FROM sn AS t1
join trx AS t2
    ON t1.serial_number = t2.lot_number
WHERE EXISTS (
    SELECT 1
    FROM trx AS t2
    WHERE t1.serial_number = t2.lot_number
)
ORDER BY t2.start_tran_date, t1.item_number, t1.location_id, t1.serial_number
"""

def main():
    try:
        print("Connecting to the EDW database...")
        # 连接到数据库并执行查询
        with pyodbc.connect(connection_string) as conn:
            print("Executing query...")
            # 将查询结果加载到 pandas DataFrame
            df = pd.read_sql(sql_query, conn)
            print("Query successful! Data loaded into DataFrame.")
        
        # 生成带有时间戳的文件名
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 获取当前用户的 Downloads 文件夹路径
        downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')
        
        # 如果 Downloads 文件夹不存在（理论上不会），则创建它
        if not os.path.exists(downloads_folder):
            os.makedirs(downloads_folder)
            
        output_filename = f'sn_in_whse_vs_347_{timestamp}.csv'
        output_path = os.path.join(downloads_folder, output_filename)
        
        # 将 DataFrame 保存为 CSV 文件
        df.to_csv(output_path, index=False, encoding='utf-8-sig')
        print(f"Success! Query results saved to: {output_path}")

    except Exception as e:
        print(f"An error occurred: {e}")
        
    finally:
        # 计算并打印总运行时间
        end_time = time.time()
        execution_time = end_time - start_time
        print(f"\nTotal execution time: {execution_time:.2f} seconds")

if __name__ == "__main__":
    main()
