import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32
from tabulate import tabulate

# 数据库连接参数 / Database Connection Parameters
CONNECTION_STRING = 'DSN=MILPROD;UID=JIMSHEN;PWD=MJ2089'

# SQL查询语句 / SQL Query
SQL_QUERY = """


WITH RCT AS (
    SELECT 
        TRIM(ITMRVAL0.STIDAD) AS SITE,
        TRIM(ITMRVAL0.ITNOAD) AS ITEM,
        TRIM(ITMRVAL0.ITDSAD) AS DES,
        ITMRVAL0.ITCLAD AS CLASS,
        ITMRVAL0.WGHTAD AS GROSS_WEIGHT,
        ITMRVAL0.AAS3AD as Net_Weight
    FROM AMFLIBL.ITMRVAL0 ITMRVAL0
),
MRPRCT AS (
    SELECT 
        TRIM(ITMRVAL0.STIDAD) AS SITE,
        TRIM(ITMRVAL0.ITNOAD) AS MRP,
        TRIM(ITMRVAL0.ITDSAD) AS DES,
        ITMRVAL0.ITCLAD AS CLASS,
        ITMRVAL0.WGHTAD AS GROSS_WEIGHT,
        ITMRVAL0.AAS3AD as Net_Weight
    FROM AMFLIBL.ITMRVAL0 ITMRVAL0
    WHERE ITMRVAL0.ITCLAD = 'RCT'
),
TYPE1 AS (
    SELECT 
        TRIM(PST.BXDSTID) AS WH,
        TRIM(PST.BXDPARENTITEMNUMBER) AS UN,
        TRIM(PST.BXDCOMPONENTITEMNUMBER) AS MRP,
        PST.BXDUSERFIELDQUANTITY4 AS GROSS,
        PST.BXDCOMPONENTITEMCLASS AS CLASS,
        PST.BXDPARENTITEMCLASS AS PCLASS
    FROM RGNFILL.PSTBOMD PST
    WHERE 
        PST.PITTYP = 1 AND BXDPARENTITEMCLASS IN ('ZACK','ZUCK','ZAMK','ZUMK')
        AND PST.BXDCOMPONENTITEMCLASS = 'RCT'
        AND PST.BXDPARENTITEMNUMBER LIKE '%UN%'
        AND PST.BXDPARENTITEMNUMBER NOT LIKE '%RUN%'
)
SELECT DISTINCT  
    'MILLENNIUM' AS "WARE HOUSE",
    T1.UN AS ITEM, 
    ROUND(1 / NULLIF(T1.GROSS,0), 0) AS "KIT/BOX",
    R.GROSS_WEIGHT * ROUND(1 / NULLIF(T1.GROSS,0), 0) AS "Weight of full box (Kg)",
    R.Net_Weight AS "Weight of each kit (Kg)",
    UPPER(M.DES) AS "Dimension box",
    CAST(REGEXP_SUBSTR(UPPER(M.DES), '[0-9]+(\.[0-9]+)?', 1, 1) AS DECIMAL(10,2)) AS L_INCH,
    CAST(REGEXP_SUBSTR(UPPER(M.DES), '[0-9]+(\.[0-9]+)?', 1, 2) AS DECIMAL(10,2)) AS W_INCH,
    CAST(REGEXP_SUBSTR(UPPER(M.DES), '[0-9]+(\.[0-9]+)?', 1, 3) AS DECIMAL(10,2)) AS H_INCH,
    'FABRIC' AS STYLE
FROM TYPE1 T1
INNER JOIN RCT R 
    ON R.SITE = T1.WH 
    AND TRIM(T1.UN) = TRIM(R.ITEM)
LEFT JOIN MRPRCT M
    ON T1.WH = M.SITE
    AND TRIM(T1.MRP) = TRIM(M.MRP)
    

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
