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

def get_peak_day_details():
    """
    查询 Peak Inbound Day (2026-01-09) 和 Peak Outbound Day (2026-02-03) 的详细数据
    明细包含: 日期, Container/Trip, Qty, Type
    """
    # 目标日期
    PEAK_INBOUND_DATE = '2026-01-09'
    PEAK_OUTBOUND_DATE = '2026-02-03'

    try:
        conn_str = get_connection_string()
        print(f"正在连接到 EDW 数据库 ({SERVER})...")
        
        with pyodbc.connect(conn_str) as conn:
            print("连接成功！正在执行明细查询...")
            
            sql_query = f"""
            -- Part 1: 收货最高日明细 (2026-01-09)
            -- 包含 151 (正) 和 951 (负)
            SELECT 
                CAST(start_tran_date AS DATE) AS [Date],
                control_number AS [Container_Trip],  -- 收货取 control_number (Container)
                SUM(CASE 
                    WHEN tran_type = '151' THEN tran_qty 
                    WHEN tran_type = '951' THEN -tran_qty 
                    ELSE 0 
                END) AS [Quantity],
                'Inbound' AS [Type]
            FROM Distribution_Warehouse_Wholesale.TranLog WITH (NOLOCK)
            WHERE 
                wh_id = '335' 
                AND tran_type IN ('151', '951')
                AND CAST(start_tran_date AS DATE) = '{PEAK_INBOUND_DATE}'
            GROUP BY CAST(start_tran_date AS DATE), control_number

            UNION ALL

            -- Part 2: 出货最高日明细 (2026-02-03)
            -- 出货取 control_number_2 (Trip)
            SELECT 
                CAST(start_tran_date AS DATE) AS [Date],
                control_number_2 AS [Container_Trip], -- 出货取 control_number_2 (Trip)
                SUM(tran_qty) AS [Quantity],
                'Outbound' AS [Type]
            FROM Distribution_Warehouse_Wholesale.TranLog WITH (NOLOCK)
            WHERE 
                wh_id = '335' 
                AND tran_type = '347'
                AND CAST(start_tran_date AS DATE) = '{PEAK_OUTBOUND_DATE}'
            GROUP BY CAST(start_tran_date AS DATE), control_number_2

            ORDER BY [Type], [Date], [Container_Trip];
            """
            
            df = pd.read_sql(sql_query, conn)
            
            if not df.empty:
                print(f"\n=== Peak Day 明细报表 (Inbound: {PEAK_INBOUND_DATE}, Outbound: {PEAK_OUTBOUND_DATE}) ===")
                df['Date'] = pd.to_datetime(df['Date'])
                
                # 打印预览
                print(df.head(20).to_string(index=False))
                
                # 保存 Excel
                output_file = 'Peak_Day_Details_wh335.xlsx'
                df.to_excel(output_file, index=False)
                print(f"\n完整明细已保存至: {output_file}")
                
                # 简单统计
                summary = df.groupby('Type')['Container_Trip'].nunique()
                print("\n[统计 - Unique Container/Trip Count]")
                print(summary)
            else:
                print("未查询到数据。")

    except pyodbc.Error as ex:
        print(f"\n[连接错误]: {ex}")
    except Exception as e:
        print(f"\n发生错误: {e}")

if __name__ == "__main__":
    get_peak_day_details()
