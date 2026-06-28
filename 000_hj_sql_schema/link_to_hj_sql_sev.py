import sys
import urllib.parse
from datetime import datetime
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

# ==========================================
# 数据库连接配置 (AshtonWHJSQLprod / HJ SQL Server)
# ==========================================
SERVER = 'AshtonWHJSQLprod'
DATABASE = 'AAD'
DOWNLOADS_DIR = Path.home() / 'Downloads'


def configure_console_encoding():
    """尽量避免 Windows 控制台打印中文时出现编码报错。"""
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')


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


def get_engine():
    """创建 SQLAlchemy engine，避免 pandas 直接使用 DBAPI 警告。"""
    params = urllib.parse.quote_plus(get_connection_string())
    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}", pool_pre_ping=True)


def build_output_file_path(wh_id):
    """生成 Downloads 下带时间戳的输出文件路径"""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    return DOWNLOADS_DIR / f"warehouse_{wh_id}_inventory_{timestamp}.xlsx"


def check_inventory_by_category(wh_id='335'):
    """
    查询指定仓库中 CG 和 UPH 的库存总件数
    """
    print(f"正在连接到 HJ 生产数据库 ({SERVER})...")

    try:
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

        engine = get_engine()
        with engine.connect() as conn:
            df = pd.read_sql(text(sql_query), conn)

        if not df.empty:
            output_file = build_output_file_path(wh_id)
            df.to_excel(output_file, index=False)

            print(f"【Warehouse {wh_id} 实时库存分布】")
            print("=" * 60)
            print(f"查询结果已保存到: {output_file}")

            display_df = df.copy()
            display_df['Total_Pieces'] = display_df['Total_Pieces'].apply(lambda x: f"{x:,.0f}")
            display_df['Unique_Item_Count'] = display_df['Unique_Item_Count'].apply(lambda x: f"{x:,.0f}")
            print(display_df.to_string(index=False))
            print("=" * 60)
        else:
            print("未查询到库存数据。")

    except Exception as e:
        print(f"\n发生错误: {e}")


if __name__ == "__main__":
    configure_console_encoding()
    check_inventory_by_category()
