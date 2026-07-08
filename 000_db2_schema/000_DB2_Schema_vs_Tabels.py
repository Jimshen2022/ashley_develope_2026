import os
import time
from datetime import datetime

import pandas as pd
import pyodbc as po


def fetch_data(query, connection_string='DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2091'):
    """执行 SQL 并返回 DataFrame"""
    try:
        cnxn = po.connect(connection_string, autocommit=True)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        print(f"❌ 数据获取错误: {str(e)}")
        raise


def save_csv(df, file_path):
    """保存查询结果到 CSV"""
    try:
        df.to_csv(file_path, index=False, encoding='utf-8-sig')
        print(f"\n✅ CSV 文件已保存：{file_path}")
    except Exception as e:
        print(f"❌ 保存 CSV 出错: {str(e)}")
        raise


def main():
    start_time = time.time()

    query_data = """
        SELECT SYSTEM_TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, VARCHAR(COLUMN_TEXT, 50) AS COLUMN_DESC
        FROM QSYS2.SYSCOLUMNS
    """

    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f"db2_all_schema_tables_columns_{current_time}.csv"
    downloads_path = os.path.join(os.path.expanduser('~'), 'Downloads')
    file_path = os.path.join(downloads_path, file_name)

    try:
        print("📥 正在查询 DB2 schema / table / column ...")
        df = fetch_data(query_data)
        print(f"✅ 共查询到 {len(df)} 条记录")

        print("📤 正在保存 CSV 文件...")
        save_csv(df, file_path)

    except Exception as e:
        print(f"❌ 程序运行出错: {str(e)}")
    finally:
        print(f"⏱ 总耗时: {time.time() - start_time:.2f} 秒")

Scx
if __name__ == '__main__':
    main()
