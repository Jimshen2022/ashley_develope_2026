import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32

def fetch_data(query, connection_string='DSN=MILPROD;UID=JIMSHEN;PWD=MJ2083'):
    """从数据库获取数据"""
    try:
        cnxn = po.connect(connection_string, autocommit=True)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        print(f"数据获取过程中发生错误: {str(e)}")
        raise


def save_file(data, file_path):
    """保存并格式化Excel文件"""
    try:
        # 先保存数据
        data.to_csv(file_path, index=False)
    except Exception as e:
        print(f"保存Excel文件过程中发生错误: {str(e)}")
        raise

def main():
    start_time = time.time()

    # SQL查询
    query = """
    
SELECT *
FROM  DISTLIBL.WVCNTID a
LIMIT 1000


        
    """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'mil_query_{current_time}.csv'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    try:
        print("正在获取数据...")
        df = fetch_data(query)
        print(f"成功获取 {len(df)} 行数据")

        # 如果只想显示部分数据，可以用：
        print(df.head(10))  # 显示前10行

        print("正在保存和格式化Excel文件...")
        save_file(df, file_path)

        print(f"csv文件已成功保存到: {file_path}")

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == '__main__':
    main()
