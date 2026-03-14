import pandas as pd
import pyodbc
from datetime import datetime

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

def get_daily_container_report():
    """
    查询 2025年至今 wh_id='335' 的每日进出库集装箱数量
    """
    try:
        conn_str = get_connection_string()
        print(f"正在连接到 EDW 数据库 ({SERVER})...")
        
        with pyodbc.connect(conn_str) as conn:
            print("连接成功！正在执行 SQL 查询...")
            
            sql_query = """
            -- Part 1: 出货集装箱 (Outbound)
            SELECT 
                CAST(start_tran_date AS DATE) AS [Date],
                -- 出货时，control_number 可能是订单号，control_number_2 可能是 Trip Number
                -- 假设 control_number_2 (Trip Number) 代表一次发运的车辆/集装箱
                COUNT(DISTINCT control_number_2) AS [ContainerCount], 
                'Outbound (Shipping)' AS [Type]
            FROM Distribution_Warehouse_Wholesale.TranLog WITH (NOLOCK)
            WHERE 
                wh_id = '335' 
                AND tran_type = '347'
                AND start_tran_date >= '2025-01-01'
            GROUP BY CAST(start_tran_date AS DATE)

            UNION ALL

            -- Part 2: 收货集装箱 (Inbound)
            SELECT 
                CAST(start_tran_date AS DATE) AS [Date],
                -- 收货时，control_number 通常是 Container Number
                COUNT(DISTINCT control_number) AS [ContainerCount],
                'Inbound (Receiving)' AS [Type]
            FROM Distribution_Warehouse_Wholesale.TranLog WITH (NOLOCK)
            WHERE 
                wh_id = '335' 
                AND tran_type IN ('151', '951')
                AND start_tran_date >= '2025-01-01'
            GROUP BY CAST(start_tran_date AS DATE)

            ORDER BY [Date] DESC, [Type];
            """
            
            df = pd.read_sql(sql_query, conn)
            
            if not df.empty:
                print(f"\n=== 每日集装箱进出报表 (2025至今, Whse 335) - 共 {len(df)} 行数据 ===")
                df['Date'] = pd.to_datetime(df['Date'])
                
                # 打印预览
                print(df.head(10).to_string(index=False))
                
                # 保存 Excel
                output_file = 'Daily_Container_Report_2025_wh335.xlsx'
                df.to_excel(output_file, index=False)
                print(f"\n完整报表已保存至: {output_file}")
                
                # ==========================================
                # 最高点分析
                # ==========================================
                print("\n" + "="*40)
                print("      最高点分析 (Peak Day Analysis)")
                print("="*40)

                # 找出收货最高点
                inbound_data = df[df['Type'] == 'Inbound (Receiving)']
                if not inbound_data.empty:
                    peak_idx = inbound_data['ContainerCount'].idxmax()
                    peak_date = inbound_data.loc[peak_idx, 'Date'].strftime('%Y-%m-%d')
                    peak_qty = inbound_data.loc[peak_idx, 'ContainerCount']
                    print(f"📈 收货最高点 (Peak Inbound Containers):")
                    print(f"   - 日期: {peak_date}")
                    print(f"   - 数量: {peak_qty} Containers")

                # 找出出货最高点
                outbound_data = df[df['Type'] == 'Outbound (Shipping)']
                if not outbound_data.empty:
                    peak_idx = outbound_data['ContainerCount'].idxmax()
                    peak_date = outbound_data.loc[peak_idx, 'Date'].strftime('%Y-%m-%d')
                    peak_qty = outbound_data.loc[peak_idx, 'ContainerCount']
                    print(f"📉 出货最高点 (Peak Outbound Containers):")
                    print(f"   - 日期: {peak_date}")
                    print(f"   - 数量: {peak_qty} Trips") # 此时显示 Trips 数量作为容器数量
                print("="*40)

            else:
                print("未查询到数据。")

    except pyodbc.Error as ex:
        print(f"\n[连接错误]: {ex}")
    except Exception as e:
        print(f"\n发生错误: {e}")

if __name__ == "__main__":
    get_daily_container_report()
