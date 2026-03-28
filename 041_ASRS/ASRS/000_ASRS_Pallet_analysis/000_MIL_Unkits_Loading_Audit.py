import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
from pathlib import Path
import win32com.client as win32


def fetch_data(query, connection_string='DSN=MILPROD;UID=JIMSHEN;PWD=MJ2084'):
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

WITH itm AS (
SELECT b.ITNBR, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID, b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SCOOPWIDTH,b.SKIDSIZE, b.HOUSE
           FROM AFILELIBL.ITBEXT as b
           WHERE b.HOUSE in ('51')
),
HeaderDetails AS (
    SELECT
        ContainerNumber,
        WCHCONTAINERSIZE,
        WCHDOORNUMBER,
        WCHBUILDING,
        WCHPOSTEDTIMESTAMP,
        WCHDESTINATION,
        Container#,
        H_Cubes
    FROM (
        SELECT
            TRIM(a.WCHCONTAINERNUMBER) AS ContainerNumber,
            a.WCHCONTAINERSIZE,
            a.WCHDOORNUMBER,
            a.WCHBUILDING,
            a.WCHPOSTEDTIMESTAMP,
            a.WCHDESTINATION,
            TRIM(a.WCHORIGIN) || '-' || TRIM(a.WCHCONTAINERNUMBER) || '-' || TRIM(a.WCHDESTINATION) AS Container#,
            a.WCHTOTALCUBES AS H_Cubes,
            ROW_NUMBER() OVER (PARTITION BY TRIM(a.WCHCONTAINERNUMBER) ORDER BY a.WCHPOSTEDTIMESTAMP DESC) AS rn
        FROM DISTLIBL.TBL_WVCONTAINER_HDR a
        WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
          AND a.WCHORIGIN = '51'
          AND TRIM(a.WCHCONTAINERNUMBER) NOT LIKE '%AIR%'
          AND a.WCHDESTINATION NOT IN ('001')
        UNION ALL
        SELECT
            TRIM(a.WCHCONTAINERNUMBER) AS ContainerNumber,
            a.WCHCONTAINERSIZE,
            a.WCHDOORNUMBER,
            a.WCHBUILDING,
            a.WCHPOSTEDTIMESTAMP,
            a.WCHDESTINATION,
            TRIM(a.WCHORIGIN) || '-' || TRIM(a.WCHCONTAINERNUMBER) || '-' || TRIM(a.WCHDESTINATION) || '-' || SUBSTR(CHAR(a.WCHARCHIVETIMESTAMP), 1, 13) AS Container#,
            a.WCHTOTALCUBES AS H_Cubes,
            ROW_NUMBER() OVER (PARTITION BY TRIM(a.WCHCONTAINERNUMBER) ORDER BY a.WCHPOSTEDTIMESTAMP DESC) AS rn
        FROM ASHLEYARCL.WVCNTHDA a
        WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
          AND a.WCHPOSTEDTIMESTAMP BETWEEN CURRENT DATE - 180 DAYS AND CURRENT DATE
          AND a.WCHORIGIN = '51'
          AND TRIM(a.WCHCONTAINERNUMBER) NOT LIKE '%AIR%'
          AND a.WCHDESTINATION NOT IN ('001')
    ) ranked_data
    WHERE rn = 1
),
i AS (
    SELECT
        a.ITNBR,
        MAX(a.ITMCQTY) AS ITMCQTY
    FROM AFILELIBL.ITMEXT a
    GROUP BY a.ITNBR
),
ctn AS (
    SELECT
        a.WCHCONTAINERNUMBER,
        a.WCHWEEKPO
    FROM DISTLIBL.TBL_WVCONTAINER_HDR a
    WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a.WCHORIGIN IN ('51')
    UNION ALL
    SELECT
        a1.WCHCONTAINERNUMBER,
        a1.WCHWEEKPO
    FROM ASHLEYARCL.WVCNTHDA a1
    WHERE a1.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a1.WCHPOSTEDTIMESTAMP BETWEEN CURRENT DATE - 180 DAYS AND CURRENT DATE
      AND a1.WCHORIGIN IN ('51')
),
grouped_data AS (
    SELECT
        t1.DWFDOORNUMBER as Loading_Door_Number,
        t1.DWFCONTAINERNUMBER as Container_Number,
        t1.DWFROWNUMBER as Loading_ROW_Number,
        t1.DWFFINISHITEM as Item_Number,
        hd.WCHDESTINATION as Destination,
        ctn.WCHWEEKPO as CO_Number,
        SUM(t1.DWFQUANTITY) / NULLIF(i.ITMCQTY, 0) AS cartons,
        SUM(t1.DWFQUANTITY) AS Qty,
        VARCHAR_FORMAT(MAX(t1.DWFAUDITTIME), 'YYYY-MM-DD HH24:MI:SS') AS last_scan_time
    FROM RGNFILL.TBL_CONTAINER_AUDIT_DW120RF t1
    LEFT JOIN i ON t1.DWFFINISHITEM = i.ITNBR
    LEFT JOIN HeaderDetails as hd ON t1.DWFCONTAINERNUMBER = hd.ContainerNumber
    LEFT JOIN ctn ON t1.DWFCONTAINERNUMBER = ctn.WCHCONTAINERNUMBER
    WHERE t1.DWFCONTAINERNUMBER IN (SELECT WCHCONTAINERNUMBER FROM ctn)
      AND t1.DWFAUDITTIME >= CURRENT_TIMESTAMP - 180 DAYS
    GROUP BY
        t1.DWFDOORNUMBER,
        t1.DWFCONTAINERNUMBER,
        t1.DWFROWNUMBER,
        t1.DWFFINISHITEM,
        i.ITMCQTY,
        hd.WCHDESTINATION,
        ctn.WCHWEEKPO
)
SELECT
    Loading_Door_Number,
    Container_Number,
    Loading_ROW_Number,
    Item_Number,
    Destination,
    CO_Number,
    cartons,
    Qty,
    itm.SCOOPQTY,
  CASE 
    WHEN COALESCE(itm.SCOOPQTY, 0) = 0 THEN 14
    ELSE cartons/itm.SCOOPQTY END AS Pallet_qty,    
    last_scan_time,
    CAST(LAST_SCAN_TIME AS DATE) AS Date,
    CASE
        WHEN ROW_NUMBER() OVER (
            PARTITION BY Container_Number, Item_Number 
            ORDER BY Loading_ROW_Number, last_scan_time
        ) = 1 THEN 1
        ELSE 0
    END AS SKU_count
FROM grouped_data
LEFT JOIN itm ON itm.ITNBR = grouped_data.Item_Number
ORDER BY
    Container_Number,
    Loading_ROW_Number,
    last_scan_time

            """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'mil_unkits_loading_audit_query_{current_time}.csv'
    # file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)
    file_path = Path.home() / 'Downloads' / file_name
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
