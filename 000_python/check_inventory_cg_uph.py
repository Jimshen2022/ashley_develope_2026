import pandas as pd
import pyodbc

# ==========================================
# 数据库连接配置 (AshtonWHJSQLprod / HJ SQL Server)
# ==========================================
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'

def get_connection_string():
    """生成连接字符串 (Windows Authentication)"""
    driver = '{ODBC Driver 17 for SQL Server}' 
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"  
        f"Encrypt=yes;"             
        f"TrustServerCertificate=yes;" 
    )

def check_inventory_by_category(wh_id='335'):
    """
    查询指定仓库中 CG 和 UPH 的库存总件数
    """
    print(f"正在连接到 HJ 生产数据库 ({SERVER})...")
    
    try:
        conn_str = get_connection_string()
        with pyodbc.connect(conn_str) as conn:
            print(f"连接成功！正在查询仓库 {wh_id} 的库存汇总...\n")
            
            # ---------------------------------------------------------
            # 查询: 根据 pick_put_id 分类汇总库存
            # ---------------------------------------------------------
            sql_query = f"""
            SELECT 
                CASE 
                    WHEN i.pick_put_id = 'UPH' THEN 'UPH (Upholstery/软体)'
                    WHEN i.pick_put_id = 'PALLT' THEN 'CG (Casegoods/柜类)'
                    ELSE ISNULL(i.pick_put_id, 'UNKNOWN (未分类)')
                END AS Product_Category,
                SUM(s.actual_qty) AS Total_Pieces,
                COUNT(DISTINCT s.item_number) AS Unique_Item_Count
            FROM t_stored_item s WITH (NOLOCK)
            JOIN t_item_master i WITH (NOLOCK) 
                ON s.item_number = i.item_number 
                AND s.wh_id = i.wh_id
            WHERE 
                s.wh_id = '{wh_id}' 
                AND s.actual_qty > 0
                -- 只统计存储区和拣货区等实际在库的货，排除一些虚拟储位
                AND s.status IN ('A', 'H', 'R') 
            GROUP BY 
                CASE 
                    WHEN i.pick_put_id = 'UPH' THEN 'UPH (Upholstery/软体)'
                    WHEN i.pick_put_id = 'PALLT' THEN 'CG (Casegoods/柜类)'
                    ELSE ISNULL(i.pick_put_id, 'UNKNOWN (未分类)')
                END
            ORDER BY Total_Pieces DESC;
            """
            
            df = pd.read_sql(sql_query, conn)
            
            if not df.empty:
                print(f"📦 【Warehouse {wh_id} 实时库存分布】")
                print("=" * 60)
                # 格式化输出，添加千位分隔符
                df['Total_Pieces'] = df['Total_Pieces'].apply(lambda x: f"{x:,.0f}")
                df['Unique_Item_Count'] = df['Unique_Item_Count'].apply(lambda x: f"{x:,.0f}")
                print(df.to_string(index=False))
                print("=" * 60)
            else:
                print("未查询到库存数据。")

    except pyodbc.Error as ex:
        print(f"\n[数据库连接错误]: {ex}")
    except Exception as e:
        print(f"\n发生未预期的错误: {e}")

if __name__ == "__main__":
    check_inventory_by_category()