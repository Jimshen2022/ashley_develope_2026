import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import csv

def fetch_data(query, connection_string='DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2084'):
    """执行 SQL 并返回 DataFrame"""
    try:
        cnxn = po.connect(connection_string, autocommit=True)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        print(f"❌ 数据获取错误: {str(e)}")
        raise

def get_column_desc(schema, table, connection_string='DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2084'):
    """获取字段说明（COLUMN_DESC）"""
    query = f"""
        SELECT COLUMN_NAME, VARCHAR(COLUMN_TEXT, 100) AS COLUMN_DESC
        FROM QSYS2.SYSCOLUMNS
        WHERE SYSTEM_TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{table}'
        ORDER BY ORDINAL_POSITION
    """
    df_desc = fetch_data(query, connection_string)
    return dict(zip(df_desc['COLUMN_NAME'], df_desc['COLUMN_DESC']))

def save_file_with_column_desc(df, column_desc_map, file_path):
    """保存CSV文件，包含列名 + 字段说明 + 数据内容"""
    try:
        column_names = df.columns.tolist()
        column_descs = [column_desc_map.get(col, '') for col in column_names]

        with open(file_path, mode='w', encoding='utf-8-sig', newline='') as f:
            writer = csv.writer(f)

            # 写入列名
            writer.writerow(column_names)

            # 写入字段说明
            writer.writerow(column_descs)

            # 写入数据
            for row in df.itertuples(index=False, name=None):
                writer.writerow(row)

        print(f"\n✅ CSV 文件已保存：{file_path}")

    except Exception as e:
        print(f"❌ 保存 CSV 出错: {str(e)}")
        raise

def main():
    start_time = time.time()

    schema = 'AFILELIB'
    table = 'TSININA1'

    # 查询数据（限制最多 1000 行）
    query_data = f"SELECT * FROM {schema}.{table} FETCH FIRST 1000 ROWS ONLY"

    # 保存路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'{table}_with_desc_{current_time}.csv'
    downloads_path = os.path.join(os.path.expanduser('~'), 'Downloads')
    file_path = os.path.join(downloads_path, file_name)

    try:
        print("📥 正在获取表数据...")
        df = fetch_data(query_data)

        print("📝 正在获取字段说明...")
        column_desc_map = get_column_desc(schema, table)

        print("📤 正在保存CSV文件...")
        save_file_with_column_desc(df, column_desc_map, file_path)

    except Exception as e:
        print(f"❌ 程序运行出错: {str(e)}")
    finally:
        print(f"⏱ 总耗时: {time.time() - start_time:.2f} 秒")

if __name__ == '__main__':
    main()
