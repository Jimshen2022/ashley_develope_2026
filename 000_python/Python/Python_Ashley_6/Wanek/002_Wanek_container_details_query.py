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
WITH Parameters AS (
    SELECT 
        TIMESTAMP('2024-12-20', '07:00:00') AS StartDateTime_Details,
        TIMESTAMP(CURRENT DATE, '06:59:59') AS EndDateTime_Details,     -- 今天早上 06:59:59 结束
        TIMESTAMP('2025-01-01', '07:00:00') AS StartDateTime_Header,
        TIMESTAMP(CURRENT DATE, '06:59:59') AS EndDateTime_Header       -- 今天早上 06:59:59 结束
    FROM SYSIBM.SYSDUMMY1
),

-- Item Extension table CTE
ItemExtension AS (
    SELECT 
        ITNBR,
        ITMCQTY
    FROM AFILELIBW.ITMEXT
),

-- Item RVA table CTE - Only STID = '35' (33 is copy of 35)
ItemRVA AS (
    SELECT 
        ITNBR,
        STID,
        ITCLS,
        B2Z95S,
        WEGHT
    FROM AMFLIBW.ITMRVA
    WHERE STID = '35'  -- Only origin 35, used for both 33 and 35
),

ContainerDetails AS (
    -- Combine current and archived container details
    SELECT 
        TRIM(a.WCICONTAINERNUMBER) AS ContainerNumber,
        a.WCIORIGIN,
        a.WCIDESTINATION,
        a.WCIORDER,
        TRIM(a.WCIITEMNUMBER) AS ItemNumber,
        a.WCIQUANTITYLOADED AS Qty,
        a.WCILASTMAINTENANCETIMESTAMP,
        a.WCILASTMAINTENANCEUSER,
        b.ITMCQTY,
        c.ITCLS,
        c.B2Z95S AS UnitCube,
        c.WEGHT AS UnitWeight,
        a.WCIQUANTITYLOADED * c.B2Z95S AS Cubes,
        CEIL(a.WCIQUANTITYLOADED / b.ITMCQTY) AS Cartons,
        TRIM(a.WCIORIGIN) || '-' || TRIM(a.WCICONTAINERNUMBER) || '-' || TRIM(a.WCIDESTINATION) AS Container#,
        CASE 
            WHEN a.WCIITEMNUMBER LIKE 'B%' THEN 'CG'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN c.ITCLS LIKE 'Z%K' THEN 'Un-Kits'
            WHEN c.ITCLS LIKE 'Z%Z' THEN 'ZipperCover'
            ELSE 'UPH' 
        END AS Product
    FROM DISTLIBW.TBL_WVCONTAINER_DTL_ITM a
    INNER JOIN ItemExtension b ON a.WCIITEMNUMBER = b.ITNBR
    INNER JOIN ItemRVA c ON a.WCIITEMNUMBER = c.ITNBR
    CROSS JOIN Parameters p
    WHERE a.WCIORIGIN IN ('33', '35')
        AND SUBSTR(TRIM(a.WCICONTAINERNUMBER), 1, 4) NOT IN ('AAAR','AIIR','AAIR','AIRR','AIR_','AIR1','AAII','ARRR')
    
    UNION ALL
    
    SELECT 
        TRIM(a.WCICONTAINERNUMBER),
        a.WCIORIGIN,
        a.WCIDESTINATION,
        a.WCIORDER,
        TRIM(a.WCIITEMNUMBER),
        a.WCIQUANTITYLOADED,
        a.WCILASTMAINTENANCETIMESTAMP,
        a.WCILASTMAINTENANCEUSER,
        b.ITMCQTY,
        c.ITCLS,
        c.B2Z95S,
        c.WEGHT,
        a.WCIQUANTITYLOADED * c.B2Z95S,
        CEIL(a.WCIQUANTITYLOADED / b.ITMCQTY),
        TRIM(a.WCIORIGIN) || '-' || TRIM(a.WCICONTAINERNUMBER) || '-' || TRIM(a.WCIDESTINATION) || '-' || SUBSTR(CHAR(a.WCIARCHIVETIMESTAMP), 1, 13),
        CASE 
            WHEN a.WCIITEMNUMBER LIKE 'B%' THEN 'CG'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RP'
            WHEN c.ITCLS LIKE 'Z%K' THEN 'Un-Kits'
            WHEN c.ITCLS LIKE 'Z%Z' THEN 'ZipperCover'
            ELSE 'UPH' 
        END
    FROM ASHLEYARCW.TBL_WVCONTAINER_DTL_ITM_A a
    INNER JOIN ItemExtension b ON a.WCIITEMNUMBER = b.ITNBR
    INNER JOIN ItemRVA c ON a.WCIITEMNUMBER = c.ITNBR
    CROSS JOIN Parameters p
    WHERE a.WCIORIGIN IN ('33', '35')
        AND a.WCIARCHIVETIMESTAMP BETWEEN p.StartDateTime_Details AND p.EndDateTime_Details
        AND SUBSTR(TRIM(a.WCICONTAINERNUMBER), 1, 4) NOT IN ('AAAR','AIIR','AAIR','AIRR','AIR_','AIR1','AAII','ARRR')
),
ContainerType AS (
    -- Determine if container is mixed or non-mixed
    SELECT 
        Container#,
        CASE WHEN COUNT(DISTINCT Product) = 1 THEN 'None-Mixed' ELSE 'Mixed' END AS ContainerType
    FROM ContainerDetails
    GROUP BY Container#
)
    --Determine if container is mixed or non-mixed
    SELECT *
   FROM ContainerDetails as t0
   join ContainerType as t1 on t1.Container# = t0.Container# 
   where t0.ContainerNumber = 'MEDU9546145'





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
        print(df)
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
