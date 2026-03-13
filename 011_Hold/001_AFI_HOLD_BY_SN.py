import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32
from tabulate import tabulate

# 数据库连接参数 / Database Connection Parameters
CONNECTION_STRING = 'DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2090'

# SQL查询语句 / SQL Query
SQL_QUERY = """

WITH SerialRange(SER_NUM, ENDSER, STATUS, ITEMNO, PONMON, HLDCOM, HLDUSR, HLDDAT, HLDTIM) AS (
    -- 1. 锚点：选择起始流水号，并包含所有需要保留的字段
    SELECT 
        BEGSER AS SER_NUM, 
        ENDSER, 
        STATUS, 
        ITEMNO, 
        PONMON, 
        HLDCOM, 
        HLDUSR, 
        HLDDAT, 
        HLDTIM
    FROM DISTLIB.DWHOLDITM1
    -- 如果 BEGSER 为 0，通常不需要展开，可以根据业务逻辑加个过滤
    WHERE BEGSER > 0  AND HLDUSR = 'JIMSHEN' AND STATUS = 'H'

    UNION ALL

    -- 2. 递归部分：每次加 1，直到达到结束序列号
    SELECT 
        SER_NUM + 1, 
        ENDSER, 
        STATUS, 
        ITEMNO, 
        PONMON, 
        HLDCOM, 
        HLDUSR, 
        HLDDAT, 
        HLDTIM
    FROM SerialRange
    WHERE SER_NUM < ENDSER AND HLDUSR = 'JIMSHEN' AND STATUS = 'H'
)
-- 3. 最终查询结果
SELECT 
    SER_NUM AS SERIAL_NO, -- 这是展开后的每一个流水号
    STATUS, 
    ITEMNO, 
    PONMON, 
    HLDCOM, 
    HLDUSR, 
    HLDDAT, 
    HLDTIM
FROM SerialRange
ORDER BY ITEMNO, SERIAL_NO

    

 """

# 输出文件配置 / Output File Configuration
OUTPUT_DIR = r'C:\Users\jishen\Downloads'

# Pandas 显示设置 / Pandas Display Settings
pd.set_option('display.max_columns', None)  # 显示所有列
pd.set_option('display.max_rows', None)  # 显示所有行
pd.set_option('display.width', None)  # 不限制显示宽度
pd.set_option('display.max_colwidth', None)  # 显示完整的列内容


def fetch_data(query, connection_string):
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


def print_table(df, rows=10):
    """以表格形式打印DataFrame - 使用实线网格（横线和竖线都是实线）"""
    print(tabulate(df.head(rows), headers='keys', tablefmt='light_grid', showindex=True))


# 主程序 / Main Program
def main():
    start_time = time.time()

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'afi_query_{current_time}.csv'
    file_path = os.path.join(OUTPUT_DIR, file_name)

    try:
        print("正在获取数据...")
        df = fetch_data(SQL_QUERY, CONNECTION_STRING)
        print(f"成功获取 {len(df)} 行数据")

        # 以表格形式显示前10行
        print("数据预览（前10行）：")
        print_table(df, rows=10)

        print("\n正在保存和格式化Excel文件...")
        save_file(df, file_path)

        print(f"\ncsv文件已成功保存到: {file_path}")

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == '__main__':
    main()
