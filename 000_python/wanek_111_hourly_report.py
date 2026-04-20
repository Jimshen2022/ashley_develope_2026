import pandas as pd
import pyodbc
from datetime import datetime
import os

# ==========================================
# 数据库连接配置 (ASHLEY_EDW / Microsoft Entra Integrated)
# ==========================================
SERVER = 'ashley-edw.database.windows.net'
DATABASE = 'ASHLEY_EDW'

def get_connection_string():
    """生成连接字符串 (Azure AD Integrated)"""
    driver = '{ODBC Driver 17 for SQL Server}'
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Authentication=ActiveDirectoryIntegrated;"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
        f"Connection Timeout=60;"
    )

def get_hourly_111_data():
    """
    查询 Wanek 2, Wanek 3 过去 90天 tran_type = '111' 按每小时汇总的数据
    """
    try:
        conn_str = get_connection_string()
        print(f"正在连接到 EDW 数据库 ({SERVER})...")
        
        with pyodbc.connect(conn_str) as conn:
            print("连接成功！正在执行 SQL 查询...")
            
            # 注意：在 Ashley WMS 中，Wanek 的仓库代码通常是 '31', '33', '34', '35'
            # 这里我假设 Wanek 2 是 '31'，Wanek 3 是 '33'。如果不对，请您修改 IN ('31', '33') 部分。
            sql_query = """
            SELECT 
                wh_id,
                CAST(start_tran_date AS DATE) AS TranDate,
                DATEPART(HOUR, start_tran_time) AS TranHour,
                COUNT(*) AS NumberOfTransactions, -- 交易笔数
                SUM(tran_qty) AS TotalQuantity    -- 操作总数量
            FROM Distribution_Warehouse_Wholesale.TranLog WITH (NOLOCK)
            WHERE 
                wh_id IN ('35', '33') -- 假设 31=Wanek2, 33=Wanek3
                AND tran_type = '111'
                AND start_tran_date >= CAST(DATEADD(DAY, -90, GETDATE()) AS DATE)
            GROUP BY 
                wh_id,
                CAST(start_tran_date AS DATE),
                DATEPART(HOUR, start_tran_time)
            ORDER BY 
                TranDate DESC, TranHour DESC, wh_id;
            """
            
            df = pd.read_sql(sql_query, conn)
            
            if not df.empty:
                print(f"\n=== Wanek 2 & Wanek 3: Tran Type '111' 过去 90 天每小时汇总 ===")
                # 格式化日期显示
                df['TranDate'] = pd.to_datetime(df['TranDate']).dt.strftime('%Y-%m-%d')
                
                # 打印前 20 行预览
                print(df.head(20).to_string(index=False))
                
                # 导出到 Downloads 文件夹
                downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                output_file = os.path.join(downloads_folder, f"Wanek_111_Hourly_Report_{timestamp}.csv")
                
                df.to_csv(output_file, index=False, encoding='utf-8-sig')
                print(f"\n✅ 完整数据已成功导出至: {output_file}")
                
            else:
                print("未查询到符合条件的数据。")
                print("💡 提示：请确认 Wanek 2 和 Wanek 3 的仓库代码 (wh_id) 是否为 '31' 和 '33'，如果不是，请在脚本中修改。")

    except pyodbc.Error as ex:
        print(f"\n[数据库连接错误]: {ex}")
    except Exception as e:
        print(f"\n发生未预期的错误: {e}")

if __name__ == "__main__":
    get_hourly_111_data()
