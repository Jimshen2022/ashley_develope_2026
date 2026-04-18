import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import subprocess
import sys
from tabulate import tabulate
from pathlib import Path

# ========= 🌟【可修改参数区】🌟 =========
DB_DSN = "WFVNPROD"
DB_UID = "JIMSHEN"
DB_PWD = "MJ2089"

SQL_QUERY = """
Select *
FROM DISTLIBW.TBL_WVCONTAINER_HDR a
WHERE a.WCHCONTAINERNUMBER = 'OOLU9635838'

-- UNION ALL
     
-- Select *
-- FROM ASHLEYARCW.TBL_WVCONTAINER_HDR_A  a
-- WHERE a.WCHCONTAINERNUMBER = 'OOLU9635838'
    
    
    
"""



# ⭐ 自动定位用户 Downloads 文件夹
OUTPUT_DIR = str(Path.home() / "Downloads")

# =======================================

pd.set_option('display.max_columns', None)
pd.set_option('display.max_colwidth', None)
pd.set_option('display.width', 0)


def fetch_data(query):
    try:
        connection_string = f"DSN={DB_DSN};UID={DB_UID};PWD={DB_PWD}"
        cnxn = po.connect(connection_string, autocommit=True)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        print(f"数据获取过程中发生错误: {str(e)}")
        raise


def save_file(data, file_path):
    try:
        data.to_csv(file_path, index=False)
    except Exception as e:
        print(f"保存文件过程中发生错误: {str(e)}")
        raise


def main():
    start_time = time.time()

    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f"afi_query_{current_time}.csv"
    file_path = os.path.join(OUTPUT_DIR, file_name)

    try:
        print("正在获取数据...")
        df = fetch_data(SQL_QUERY)
        print(f"成功获取 {len(df)} 行数据\n")

        print("===== 前 100 行查询结果（带表格线）=====")
        print(tabulate(df.head(100), headers="keys", tablefmt="grid", showindex=False))
        print("======================================\n")

        print("正在保存 CSV 文件...")
        save_file(df, file_path)
        print(f"CSV 文件已保存到：{file_path}")

    except Exception as e:
        print(f"程序执行失败：{str(e)}")
        raise

    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总共运行：{execution_time:.2f} 秒")


if __name__ == "__main__":
    main()
