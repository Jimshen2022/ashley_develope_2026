import pandas as pd
import pyodbc
import os
from datetime import datetime

# ==========================================
# 数据库连接配置 (Database Configuration)
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


def fetch_and_expand_asn():
    """
    连接数据库获取 ASN 数据，并使用 Pandas 在内存中展开 Serial Number (序列号)
    """
    df_final = pd.DataFrame()

    try:
        conn_str = get_connection_string()

        print(f"⏳ 正在连接到数据库 {SERVER}...")

        with pyodbc.connect(conn_str) as conn:
            print("✅ 连接成功！正在拉取主表 t_asn 数据...")

            # 注意：你原代码中把近 7 天的时间过滤注释掉了，这里我保留你的原样
            sql_asn = """
                      SELECT * \
                      FROM t_asn WITH (NOLOCK)
                      -- WHERE expected_arrival >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
                      where status IN ('NEW', 'CHECKED IN', 'CLOSED') \
                      """
            df_asn = pd.read_sql(sql_asn, conn)

            if df_asn.empty:
                print("⚠️ 未找到符合条件的 ASN 数据。")
                return df_final

            print(f"📦 找到 {len(df_asn)} 条 ASN 记录。正在拉取明细 t_asn_detail...")
            asn_ids = tuple(df_asn['asn_id'].tolist())

            if len(asn_ids) == 1:
                asn_ids_str = f"({asn_ids[0]})"
            else:
                asn_ids_str = str(asn_ids)

            sql_detail = f"SELECT * FROM t_asn_detail WITH (NOLOCK) WHERE asn_id IN {asn_ids_str}"
            df_detail = pd.read_sql(sql_detail, conn)

            if df_detail.empty:
                print("⚠️ 未找到对应的明细数据。")
                return df_asn

            print("🪄 正在内存中执行 Serial Number 序列号展开 (Explode)...")
            df_detail['serial_number_start'] = df_detail['serial_number_start'].astype(int)
            df_detail['serial_number_end'] = df_detail['serial_number_end'].astype(int)

            df_detail['sn_list'] = df_detail.apply(
                lambda row: list(range(row['serial_number_start'], row['serial_number_end'] + 1)),
                axis=1
            )

            df_expanded_sn = df_detail.explode('sn_list').rename(columns={'sn_list': 'serial_number'})
            df_expanded_sn = df_expanded_sn.drop(columns=['serial_number_start', 'serial_number_end'])

            print("🔗 正在合并主表与明细数据 (Merge)...")
            df_final = pd.merge(df_asn, df_expanded_sn, on='asn_id', how='inner')

    except pyodbc.Error as ex:
        print(f"\n❌ [数据库连接/查询错误]: {ex}")
    except Exception as e:
        print(f"\n❌ 发生未预期的错误: {e}")

    return df_final


def export_to_excel(df):
    """
    将 DataFrame 导出到 Windows 默认的 Downloads (下载) 文件夹
    """
    if df.empty:
        print("🛑 最终数据表为空，取消导出 Excel。")
        return

    try:
        # 自动获取当前 Windows 用户的 Downloads 文件夹路径
        downloads_folder = os.path.join(os.path.expanduser('~'), 'Downloads')

        # 生成带时间戳 (Timestamp) 的文件名
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_name = f"ASN_Expanded_Data_{timestamp}.xlsx"
        output_file = os.path.join(downloads_folder, file_name)

        print(f"💾 正在将 {len(df)} 行数据写入 Excel 文件，这可能需要几十秒时间，请稍候...")

        # 导出为 Excel (Export to Excel)
        df.to_excel(output_file, index=False, engine='openpyxl')

        print("=" * 60)
        print(f"🎉 成功！(Success!)")
        print(f"📁 文件已保存至: {output_file}")
        print("=" * 60)

    except PermissionError:
        print("\n❌ [权限错误]: 无法保存文件。如果你打开了同名文件，请先关闭它然后再试一次。")
    except Exception as e:
        print(f"\n❌ 导出 Excel 时发生错误: {e}")


# ==========================================
# 主程序入口 (Main Execution Block)
# ==========================================
if __name__ == "__main__":
    print("🚀 开始执行 ASN 数据处理脚本...")

    # 1. 获取并处理数据
    result_df = fetch_and_expand_asn()

    # 2. 导出到 Excel
    export_to_excel(result_df)