import pandas as pd
import pyodbc
from datetime import datetime
import os

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

def check_item_inventory(item_number, wh_id='335'):
    """
    查询指定物料的详细库存信息（包括物料主数据、详细储位信息），并导出到 Downloads 文件夹
    """
    print(f"正在连接到 HJ 生产数据库 ({SERVER})...")
    
    try:
        conn_str = get_connection_string()
        with pyodbc.connect(conn_str) as conn:
            print(f"连接成功！正在查询物料 '{item_number}' 的详细信息...\n")
            
            # ---------------------------------------------------------
            # 联合查询：t_stored_item (库存) + t_location (储位属性) + t_item_master (物料主数据)
            # ---------------------------------------------------------
            sql_query = f"""
            SELECT 
                s.wh_id,
                s.item_number,
                i.description AS item_description,
                i.class_id AS item_class,
                i.unit_weight,
                i.unit_volume,
                s.location_id,
                l.type AS location_type,
                l.zone_1 AS location_zone, -- 假设有 zone 字段
                s.status AS inventory_status,
                CASE 
                    WHEN s.status = 'A' THEN 'Available'
                    WHEN s.status = 'H' THEN 'Hold'
                    WHEN s.status = 'I' THEN 'In-Transit'
                    WHEN s.status = 'D' THEN 'Damaged'
                    ELSE s.status 
                END AS status_desc,
                s.actual_qty,
                s.lot_number AS serial_number
            FROM t_stored_item s WITH (NOLOCK)
            LEFT JOIN t_location l WITH (NOLOCK) 
                ON s.location_id = l.location_id AND s.wh_id = l.wh_id
            LEFT JOIN t_item_master i WITH (NOLOCK) 
                ON s.item_number = i.item_number AND s.wh_id = i.wh_id
            WHERE 
                s.wh_id = '{wh_id}' 
                AND s.item_number = '{item_number}'
                AND s.actual_qty > 0
            ORDER BY 
                s.location_id, s.status;
            """
            
            df = pd.read_sql(sql_query, conn)
            
            if df.empty:
                print(f"警告: 在仓库 {wh_id} 中未找到物料 {item_number} 的库存记录，或库存为 0。")
                return
            
            # 打印控制台预览 (只展示部分核心字段防止太宽)
            print("📍 【详细库存与储位分布】 (预览):")
            preview_cols = ['item_number', 'item_class', 'location_id', 'location_type', 'status_desc', 'actual_qty']
            print(df[preview_cols].head(20).to_string(index=False))
            print("-" * 60)
            
            # ---------------------------------------------------------
            # 导出到 Downloads 文件夹
            # ---------------------------------------------------------
            # 自动获取当前 Windows 用户的 Downloads 文件夹路径
            downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')
            
            # 生成带时间戳的文件名
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            file_name = f"Inventory_Detail_{item_number}_Whse{wh_id}_{timestamp}.csv"
            output_file = os.path.join(downloads_folder, file_name)
            
            # 导出为 CSV，使用 utf-8-sig 防止 Excel 打开中文乱码
            df.to_csv(output_file, index=False, encoding='utf-8-sig')
            
            print(f"✅ 查询完成！")
            print(f"总计找到 {len(df)} 条明细记录。")
            print(f"📁 详细数据已成功导出至: {output_file}")
            print("=" * 60)

    except pyodbc.Error as ex:
        print(f"\n[数据库连接错误]: {ex}")
    except Exception as e:
        print(f"\n发生未预期的错误: {e}")

if __name__ == "__main__":
    TARGET_ITEM = 'B3381-99'
    check_item_inventory(TARGET_ITEM)
