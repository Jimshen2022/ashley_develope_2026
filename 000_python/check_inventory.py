import pandas as pd
from datetime import datetime
import os
import sys

# ==========================================
# 数据库连接配置 (AshtonWHJSQLprod / HJ SQL Server)
# ==========================================
SERVER = os.getenv('HJ_SERVER', 'AshtonWHJSQLprod')
DATABASE = os.getenv('HJ_DATABASE', 'AAD')
DRIVER = os.getenv('HJ_DRIVER', 'ODBC Driver 17 for SQL Server')
CONNECT_TIMEOUT = os.getenv('HJ_CONNECT_TIMEOUT', '300')

SAMPLE_INVENTORY_ROWS = [
    {
        'wh_id': '335',
        'item_number': 'B3381-99',
        'item_description': 'Sample sofa frame',
        'item_class': 'UPH',
        'unit_weight': 82.5,
        'unit_volume': 46.2,
        'location_id': 'A01-01-01',
        'location_type': 'PICK',
        'location_zone': 'UPH',
        'inventory_status': 'A',
        'status_desc': 'Available',
        'actual_qty': 12,
        'serial_number': 'SN-SAMPLE-001',
    },
    {
        'wh_id': '335',
        'item_number': 'B3381-99',
        'item_description': 'Sample sofa frame',
        'item_class': 'UPH',
        'unit_weight': 82.5,
        'unit_volume': 46.2,
        'location_id': 'A01-01-02',
        'location_type': 'RESERVE',
        'location_zone': 'UPH',
        'inventory_status': 'H',
        'status_desc': 'Hold',
        'actual_qty': 3,
        'serial_number': 'SN-SAMPLE-002',
    },
    {
        'wh_id': '335',
        'item_number': 'B3381-99',
        'item_description': 'Sample sofa frame',
        'item_class': 'UPH',
        'unit_weight': 82.5,
        'unit_volume': 46.2,
        'location_id': 'B02-04-03',
        'location_type': 'BULK',
        'location_zone': 'BULK',
        'inventory_status': 'A',
        'status_desc': 'Available',
        'actual_qty': 6,
        'serial_number': 'SN-SAMPLE-003',
    },
]

def get_connection_string():
    """生成连接字符串 (Windows Authentication)"""
    return (
        f"DRIVER={{{DRIVER}}};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"  
        f"Encrypt=yes;"             
        f"TrustServerCertificate=yes;" 
        f"Connection Timeout={CONNECT_TIMEOUT};"
    )

def get_sample_inventory_data(item_number, wh_id):
    """Return deterministic sample inventory rows for offline environment setup."""
    df = pd.DataFrame(SAMPLE_INVENTORY_ROWS)
    return df[(df['wh_id'] == wh_id) & (df['item_number'] == item_number)].copy()

def check_item_inventory(item_number, wh_id='335'):
    """
    查询指定物料的详细库存信息（包括物料主数据、详细储位信息），并导出到 Downloads 文件夹
    """
    print(f"使用模拟数据测试 HJ 库存查询 ({SERVER} / {DATABASE})...")
    
    try:
        print(f"模拟连接成功！正在查询物料 '{item_number}' 的详细信息...\n")
        df = get_sample_inventory_data(item_number, wh_id)
            
        if df.empty:
            print(f"警告: 在仓库 {wh_id} 中未找到物料 {item_number} 的模拟库存记录，或库存为 0。")
            return False
            
        # 打印控制台预览 (只展示部分核心字段防止太宽)
        print("📍 【详细库存与储位分布】 (预览):")
        preview_cols = ['item_number', 'item_class', 'location_id', 'location_type', 'status_desc', 'actual_qty']
        print(df[preview_cols].head(20).to_string(index=False))
        print("-" * 60)
            
        # ---------------------------------------------------------
        # 导出到 Downloads 文件夹
        # ---------------------------------------------------------
        # 自动获取当前用户的 Downloads 文件夹路径
        downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')
        os.makedirs(downloads_folder, exist_ok=True)
            
        # 生成带时间戳的文件名
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_name = f"Inventory_Detail_{item_number}_Whse{wh_id}_{timestamp}.csv"
        output_file = os.path.join(downloads_folder, file_name)
            
        # 导出为 CSV，使用 utf-8-sig 防止 Excel 打开中文乱码
        df.to_csv(output_file, index=False, encoding='utf-8-sig')
            
        print(f"✅ 模拟查询完成！")
        print(f"总计找到 {len(df)} 条明细记录。")
        print(f"📁 详细数据已成功导出至: {output_file}")
        print("=" * 60)
        return True

    except Exception as e:
        print(f"\n发生未预期的错误: {e}")
    return False

if __name__ == "__main__":
    TARGET_ITEM = os.getenv('HJ_ITEM', 'B3381-99')
    TARGET_WH_ID = os.getenv('HJ_WH_ID', '335')
    sys.exit(0 if check_item_inventory(TARGET_ITEM, TARGET_WH_ID) else 1)
