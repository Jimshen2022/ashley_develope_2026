import pandas as pd
import numpy as np
import pyodbc
import os
import glob
import time
import csv
from datetime import datetime

# ==========================================
# 1. 核心配置区 (Configuration Zone)
# ==========================================
# 数据库配置
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'

# SharePoint 本地同步盘路径 (请将这里的 "你的用户名" 替换为你电脑的实际用户名，或直接粘贴绝对路径)
# 例如: r"C:\Users\ashton\Ashley Furniture Industries\Asia Warehouse Operations - ASN"
SHAREPOINT_FOLDER = r"D:\OneDriver\Ashley Furniture Industries, Inc\Asia Warehouse Operations - ASN"

# ==========================================
# 2. 数据库连接模块 (Database Connection)
# ==========================================
def get_connection_string():
    """生成连接字符串 (Windows 身份验证)"""
    driver = '{ODBC Driver 17 for SQL Server}'
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
    )

# ==========================================
# 3. 数据拉取与处理模块 (Data Fetching & Processing)
# ==========================================
def fetch_and_process_data():
    df_final = pd.DataFrame()

    try:
        conn_str = get_connection_string()
        print(f"⏳ 正在连接数据库 {SERVER}...")

        with pyodbc.connect(conn_str) as conn:
            print("✅ 连接成功！正在拉取主表与基础关联数据...")
            
            sql_master = """
                WITH latest_trailer AS (
                    SELECT ta.asn_id, ta.trailer_id
                    FROM t_trailer_asn ta WITH (NOLOCK)
                    INNER JOIN (
                        SELECT ta2.asn_id, MAX(tr.entered_yard) AS max_entered_yard
                        FROM t_trailer_asn ta2 WITH (NOLOCK)
                        INNER JOIN t_trailer tr WITH (NOLOCK) ON ta2.trailer_id = tr.trailer_id
                        GROUP BY ta2.asn_id
                    ) mx ON ta.asn_id = mx.asn_id
                    INNER JOIN t_trailer tr WITH (NOLOCK) ON ta.trailer_id = tr.trailer_id
                                            AND tr.entered_yard = mx.max_entered_yard
                )
                SELECT 
                    a.asn_id, a.asn_number, a.status AS asn_status, a.equipment_id, a.trailer_type_name, 
                    a.expected_arrival, a.vendor_id, a.total_quantity, a.total_volume,
                    v.vendor_name,
                    tr.trailer_id, tr.status AS trailer_status, tr.entered_yard, tr.exited_yard,
                    loc.location_name
                FROM t_asn AS a WITH (NOLOCK)
                LEFT JOIN latest_trailer AS lt ON a.asn_id = lt.asn_id
                LEFT JOIN t_trailer AS tr WITH (NOLOCK) ON lt.trailer_id = tr.trailer_id
                LEFT JOIN t_ya_location AS loc WITH (NOLOCK) ON tr.location_id = loc.location_id
                LEFT JOIN t_vendor AS v WITH (NOLOCK) ON a.vendor_id = v.vendor_id
                WHERE a.status IN ('NEW', 'CHECKED IN')
            """
            df_master = pd.read_sql(sql_master, conn)

            if df_master.empty:
                print("⚠️ 未找到主表数据。")
                return df_final

            print(f"📦 找到 {len(df_master)} 条 ASN 记录。正在拉取明细并展开序列号...")
            asn_ids = tuple(df_master['asn_id'].dropna().unique().tolist())
            
            if not asn_ids:
                return df_final

            asn_ids_str = f"({asn_ids[0]})" if len(asn_ids) == 1 else str(asn_ids)
            sql_detail = f"SELECT * FROM t_asn_detail WITH (NOLOCK) WHERE asn_id IN {asn_ids_str}"
            df_detail = pd.read_sql(sql_detail, conn)

            # Pandas 内存展开 Serial Number
            df_detail['serial_number_start'] = pd.to_numeric(df_detail['serial_number_start']).fillna(0).astype(int)
            df_detail['serial_number_end'] = pd.to_numeric(df_detail['serial_number_end']).fillna(0).astype(int)

            df_detail['sn_list'] = df_detail.apply(
                lambda row: list(range(row['serial_number_start'], row['serial_number_end'] + 1)), axis=1
            )
            df_expanded_sn = df_detail.explode('sn_list').rename(columns={'sn_list': 'serial_number'})
            df_expanded_sn = df_expanded_sn.drop(columns=['serial_number_start', 'serial_number_end'])

            print("🔗 正在合并数据...")
            df_final = pd.merge(df_master, df_expanded_sn, on='asn_id', how='inner')

    except pyodbc.Error as ex:
        print(f"\n❌ [数据库错误]: {ex}")
        return df_final
    except Exception as e:
        print(f"\n❌ [未预期错误]: {e}")
        return df_final

    # 业务逻辑计算 (NumPy 矢量化加速)
    if not df_final.empty:
        print("🧮 正在执行业务逻辑计算...")
        df_final['entered_yard'] = pd.to_datetime(df_final['entered_yard'])
        df_final['exited_yard'] = pd.to_datetime(df_final['exited_yard'])
        df_final['expected_arrival'] = pd.to_datetime(df_final['expected_arrival'])
        
        current_time = pd.Timestamp.now()

        # 1. 计算 hours_in_yard
        exited_or_now = df_final['exited_yard'].fillna(current_time)
        df_final['hours_in_yard'] = (exited_or_now - df_final['entered_yard']).dt.total_seconds() / 3600.0
        df_final['hours_in_yard'] = df_final['hours_in_yard'].round(1)

        # 2. 计算 hours_in_yard_bucket
        def get_bucket(h):
            if pd.isna(h): return None
            if h < 4: return '[a] 0-4h'
            if h < 8: return '[b] 4-8h'
            if h < 24: return '[c] 8-24h'
            if h < 48: return '[d] 24-48h'
            return '[e] 48h+'
        df_final['hours_in_yard_bucket'] = df_final['hours_in_yard'].apply(get_bucket)

        # 3. 计算 container_status
        cond_status = [
            df_final['location_name'].isna(),
            df_final['exited_yard'].notna(),
            df_final['location_name'].str.startswith('D', na=False),
            df_final['location_name'].str.contains('YARD', na=False)
        ]
        choices_status = ['In_Transit', 'Completed', 'On_Door', 'In_Yard']
        df_final['container_status'] = np.select(cond_status, choices_status, default='CHECK')

        # 4. 计算 shift
        hour = df_final['entered_yard'].dt.hour
        df_final['shift'] = np.where(
            df_final['entered_yard'].isna(), None, 
            np.where((hour >= 7) & (hour <= 19), 'D', 'N')
        )

        # 5. 计算 shift_date
        cond_date = [
            df_final['entered_yard'].isna(),
            (hour >= 0) & (hour <= 6)
        ]
        choices_date = [
            df_final['expected_arrival'].dt.date,
            (df_final['entered_yard'] - pd.Timedelta(days=1)).dt.date
        ]
        df_final['shift_date'] = np.select(cond_date, choices_date, default=df_final['entered_yard'].dt.date)

        # 6. 数据清洗 (防止导出 CSV 错列或换行)
        print("🧹 正在清洗文本脏数据...")
        text_cols = df_final.select_dtypes(include=['object', 'string']).columns
        for col in text_cols:
            df_final[col] = df_final[col].astype(str).str.replace(',', '，', regex=False).str.replace('\n', ' ', regex=False).str.replace('\r', '', regex=False)
            df_final[col] = df_final[col].replace('nan', '')

    return df_final

# ==========================================
# 4. 导出与清理模块 (Export & Cleanup)
# ==========================================
def export_and_cleanup(df):
    if df.empty:
        print("🛑 数据为空，取消导出。")
        return

    # 检查配置的 SharePoint 文件夹是否存在
    if not os.path.exists(SHAREPOINT_FOLDER):
        print(f"\n❌ [路径错误]: 找不到文件夹 {SHAREPOINT_FOLDER}")
        print("👉 请检查代码顶部的 SHAREPOINT_FOLDER 路径是否正确配置，或者是否已完成 OneDrive 文件夹同步。")
        return

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"ashton_asn_sn_extended_{timestamp}.csv"
    output_file = os.path.join(SHAREPOINT_FOLDER, file_name)
    
    # -------------------------
    # A. 写入新文件
    # -------------------------
    try:
        print(f"💾 正在将 {len(df)} 行数据极速导出至 SharePoint 文件夹...")
        # 针对 80万级数据，默认关闭引号包裹以最大化提升速度；utf-8-sig 保证 Excel 中文不乱码
        df.to_csv(output_file, index=False, encoding='utf-8-sig',quoting=csv.QUOTE_ALL)
        print(f"🎉 成功保存至: {output_file}")
        print("☁️ (OneDrive 将在后台自动把此文件同步至云端)")
    except Exception as e:
        print(f"\n❌ [导出错误]: {e}")
        return

    # -------------------------
    # B. 自动清理 15 天前的文件
    # -------------------------
    print("\n🧹 正在检查并清理 15 天前的历史文件...")
    now = time.time()
    fifteen_days_in_seconds = 15 * 24 * 60 * 60 
    
    # 匹配目标文件夹下所有的目标前缀文件
    search_pattern = os.path.join(SHAREPOINT_FOLDER, "ashton_asn_sn_extended_*.csv")
    files = glob.glob(search_pattern)
    
    deleted_count = 0
    for file in files:
        file_creation_time = os.path.getctime(file)
        
        if (now - file_creation_time) > fifteen_days_in_seconds:
            try:
                os.remove(file)
                print(f"   🗑️ 已删除过期文件: {os.path.basename(file)}")
                deleted_count += 1
            except Exception as e:
                print(f"   ⚠️ 无法删除文件 {os.path.basename(file)}: {e}")
                
    print(f"✅ 清理完成，本次共删除了 {deleted_count} 个过期文件。")
    print("=" * 60)

# ==========================================
# 主程序入口 (Main Execution)
# ==========================================
if __name__ == "__main__":
    print("🚀 开始执行 ASN 数据自动化流水线...\n" + "=" * 60)
    
    start_time = time.time()
    
    # 1. 获取并处理数据
    result_df = fetch_and_process_data()
    
    # 2. 导出并清理旧文件
    export_and_cleanup(result_df)
    
    end_time = time.time()
    print(f"\n⏱️ 脚本执行完毕！总耗时: {round(end_time - start_time, 2)} 秒")