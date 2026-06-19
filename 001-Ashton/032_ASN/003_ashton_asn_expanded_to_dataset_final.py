import pandas as pd
import numpy as np
import pyodbc
import os
from datetime import datetime
import csv

# ==========================================
# 数据库连接配置 (Database Configuration)
# ==========================================
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'

def get_connection_string():
    """生成连接字符串 / Generate connection string"""
    driver = '{ODBC Driver 17 for SQL Server}'
    return (
        f"DRIVER={driver};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
    )

def fetch_and_process_data():
    df_final = pd.DataFrame()

    try:
        conn_str = get_connection_string()
        print(f"⏳ 正在连接数据库 / Connecting to DB {SERVER}...")

        with pyodbc.connect(conn_str) as conn:
            print("✅ 连接成功！正在拉取主表与基础关联数据 / Fetching master & join data...")
            
            # 将最新的 Trailer 和 Location 关联逻辑留在 SQL，这是最有效率的
            # Keep the latest Trailer and Location join logic in SQL for efficiency
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
                WHERE a.status IN ('NEW', 'CHECKED IN', 'CLOSED')
                  -- AND a.expected_arrival >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
            """
            df_master = pd.read_sql(sql_master, conn)

            if df_master.empty:
                print("⚠️ 未找到主表数据 / No master data found.")
                return df_final

            print(f"📦 找到 {len(df_master)} 条 ASN 记录。正在拉取明细... / Fetching details...")
            asn_ids = tuple(df_master['asn_id'].dropna().unique().tolist())
            
            if not asn_ids:
                return df_final

            asn_ids_str = f"({asn_ids[0]})" if len(asn_ids) == 1 else str(asn_ids)
            sql_detail = f"SELECT * FROM t_asn_detail WITH (NOLOCK) WHERE asn_id IN {asn_ids_str}"
            df_detail = pd.read_sql(sql_detail, conn)

            print("🪄 正在内存中执行行展开 / Expanding Serial Numbers in memory...")
            df_detail['serial_number_start'] = pd.to_numeric(df_detail['serial_number_start']).fillna(0).astype(int)
            df_detail['serial_number_end'] = pd.to_numeric(df_detail['serial_number_end']).fillna(0).astype(int)

            df_detail['sn_list'] = df_detail.apply(
                lambda row: list(range(row['serial_number_start'], row['serial_number_end'] + 1)), axis=1
            )
            df_expanded_sn = df_detail.explode('sn_list').rename(columns={'sn_list': 'serial_number'})
            df_expanded_sn = df_expanded_sn.drop(columns=['serial_number_start', 'serial_number_end'])

            print("🔗 正在合并数据 / Merging data...")
            df_final = pd.merge(df_master, df_expanded_sn, on='asn_id', how='inner')

    except pyodbc.Error as ex:
        print(f"\n❌ [数据库错误 / DB Error]: {ex}")
        return df_final
    except Exception as e:
        print(f"\n❌ [未预期错误 / Unexpected Error]: {e}")
        return df_final

    # ==========================================
    # 在 Python 中执行计算逻辑 (Pandas Vectorized Calculations)
    # ==========================================
    if not df_final.empty:
        print("🧮 正在执行业务逻辑计算 / Executing business logic calculations...")
        
        # 强制转换为日期时间格式 / Convert to datetime
        df_final['entered_yard'] = pd.to_datetime(df_final['entered_yard'])
        df_final['exited_yard'] = pd.to_datetime(df_final['exited_yard'])
        df_final['expected_arrival'] = pd.to_datetime(df_final['expected_arrival'])
        
        current_time = pd.Timestamp.now()

        # 1. 计算 hours_in_yard
        # 相当于: DATEDIFF(MINUTE, entered_yard, COALESCE(exited_yard, GETDATE())) / 60.0
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

        # 3. 计算 container_status (使用 np.select 替代 CASE WHEN)
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

        # 数据清洗：防止 CSV 错列 (Data cleaning to prevent CSV column shift)
        print("🧹 正在清洗文本脏数据 / Cleaning dirty text data...")
        text_cols = df_final.select_dtypes(include=['object', 'string']).columns
        for col in text_cols:
            df_final[col] = df_final[col].astype(str).str.replace(',', '，', regex=False).str.replace('\n', ' ', regex=False).str.replace('\r', '', regex=False)
            df_final[col] = df_final[col].replace('nan', '')

    return df_final

def export_to_csv(df):
    if df.empty:
        print("🛑 数据为空，取消导出 / Data is empty, export cancelled.")
        return

    try:
        downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_name = f"ASN_Expanded_Data_{timestamp}.csv"
        output_file = os.path.join(downloads_folder, file_name)
        
        print(f"💾 正在导出 {len(df)} 行数据至 CSV / Exporting data to CSV...")
        
        # 强制添加双引号，进一步防止错列 / QUOTE_ALL prevents any remaining delimiter issues
        df.to_csv(output_file, index=False, encoding='utf-8-sig', quoting=csv.QUOTE_ALL)
        
        print("=" * 60)
        print(f"🎉 成功！文件已保存至 / Success! File saved to: \n{output_file}")
        print("=" * 60)

    except Exception as e:
        print(f"\n❌ [导出错误 / Export Error]: {e}")

if __name__ == "__main__":
    print("🚀 开始执行 / Starting Execution...")
    result_df = fetch_and_process_data()
    export_to_csv(result_df)