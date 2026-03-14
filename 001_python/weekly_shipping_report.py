import pandas as pd
import pyodbc
from datetime import datetime, timedelta

# ==========================================
# 数据库连接配置 (ASHLEY_EDW / Microsoft Entra Integrated)
# ==========================================
SERVER = 'ashley-edw.database.windows.net'
DATABASE = 'ASHLEY_EDW'

def get_connection_string():
    """
    生成连接字符串
    使用 Microsoft Entra Integrated (Azure AD Integrated) 认证
    """
    # 尝试使用 ODBC Driver 17 或 18
    # 如果您的电脑安装的是 18，请手动改为 18
    driver = '{ODBC Driver 17 for SQL Server}' 
    
    conn_str = (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        # Microsoft Entra Integrated 认证
        f"Authentication=ActiveDirectoryIntegrated;" 
        # 强制加密与信任证书
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
        f"Connection Timeout=30;"
    )
    return conn_str

def get_weekly_shipping_data():
    """
    连接 ASHLEY_EDW，查询 Warehouse 335 过去20周的出货数据，并按周六汇总
    """
    try:
        conn_str = get_connection_string()
        print(f"正在连接到数据库: {SERVER} ({DATABASE})...")
        print("认证方式: Microsoft Entra Integrated")
        
        # 使用 with 语句自动管理连接关闭
        with pyodbc.connect(conn_str) as conn:
            print("连接成功！正在执行 SQL 查询...")
            
            # SQL 查询：
            # 1. 筛选 Warehouse 335 (Ashton)
            # 2. 筛选 Tran Type 347 (Shipping)
            # 3. 过去 20 周
            # 4. 按周六 (Week Ending Saturday) 汇总
            sql_query = """
            SET DATEFIRST 7; -- 设置周日为第一天

            SELECT 
                -- 计算周六的日期 (Week Ending Saturday)
                CAST(DATEADD(DAY, 7 - DATEPART(WEEKDAY, start_tran_date), start_tran_date) AS DATE) AS WeekEndingSaturday,
                
                -- 统计指标
                COUNT(DISTINCT control_number_2) as TotalTrips, -- 唯一 Trip 数量
                COUNT(*) as TotalLines,                         -- 总行数
                SUM(tran_qty) as TotalQuantity                  -- 总出货数量

            FROM Distribution_Warehouse_Wholesale.TranLog WITH (NOLOCK)
            WHERE 
                wh_id = '335' -- Ashton Warehouse
                AND tran_type = '347' -- Shipping Transaction
                AND start_tran_date >= DATEADD(WEEK, -20, GETDATE())
            GROUP BY 
                CAST(DATEADD(DAY, 7 - DATEPART(WEEKDAY, start_tran_date), start_tran_date) AS DATE)
            ORDER BY 
                WeekEndingSaturday DESC;
            """
            
            # 使用 Pandas 读取数据
            df = pd.read_sql(sql_query, conn)
            
            if not df.empty:
                print("\n=== Ashton (Whse 335) 过去 20 周出货统计 (EDW 数据源) ===")
                # 格式化日期列
                df['WeekEndingSaturday'] = pd.to_datetime(df['WeekEndingSaturday']).dt.strftime('%Y-%m-%d')
                
                # 打印表格
                print(df.to_string(index=False))
                
                # 如果需要保存为 Excel，请取消下面两行的注释
                # output_file = 'Ashton_Shipping_Report_EDW.xlsx'
                # df.to_excel(output_file, index=False)
                # print(f"\n结果已保存至: {output_file}")
            else:
                print("查询成功，但未返回任何数据 (可能是 wh_id 或 tran_type 不匹配)。")

    except pyodbc.Error as ex:
        print("\n[连接错误]")
        print(f"错误代码: {ex.args[0]}")
        print(f"错误信息: {ex.args[1]}")
        print("-" * 30)
        print("常见排查建议:")
        print("1. 请确保已安装 'ODBC Driver 17 for SQL Server' (或 18)。")
        print("2. 请确保当前 Windows 账户已同步到 Azure AD 且有数据库访问权限。")
        print("3. 如果提示 'Datasource name not found'，请检查驱动名称是否正确。")
    except Exception as e:
        print(f"\n发生未预期的错误: {e}")

if __name__ == "__main__":
    get_weekly_shipping_data()
