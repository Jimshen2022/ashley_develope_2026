import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32

def fetch_data(query, connection_string='DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2083'):
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

WITH ss as (
    select t.SSINVR,
        t.SSORNO,
        t.SSCONO,
        t.SSCSNO as "Customer Number",
        trim(t.SSSTNM) || '(' || TRIM(t.SSCSNO) || '/' ||  TRIM(t.SSSPNO) || ')' as "Sold to Name",
        trim(t.SSSTA1) || '' || TRIM(t.SSSTA2) as "Sold to Address",
         TRIM(t.SSSTA3) || ',' || TRIM(t.SSSTST) || '  ' || TRIM(t.SSSTZC) as "sold to CITY/STATE/ZIP",
         t.SSSPNO,
         t.SSSPNM as "Ship to Name",
         trim(t.SSSPA1) || ' ' || TRIM(t.SSSPA2) as "Ship to Address",
         TRIM(t.SSSPA3) || ',' || TRIM(t.SSSPST) || ' ' || TRIM(t.SSSPZC) as "Ship to CITY/STATE/ZIP",
         t.SSSCTY,
         t.SSSPCN
            FROM AFILELIB.TSSSIN as t
),
po AS (
    SELECT
        t.HOUSE,
        t.ORDNO,
        t.VNDNR,
        t.PSTTS,
        t.UU25PM
    FROM AMFLIBA.POMAST AS t
    WHERE t.HOUSE IN ('C','C35') AND t.PSTTS = '30'
),
trip as (
    SELECT t.XNINVR,
           t.XNORNO,
           t.XNTRPN
    FROM AFILELIB.TSINXN AS t
    WHERE t.XNTRPN IS NOT NULL
)
    SELECT
        t.ININVR as "Invoice Number",
        t.INORNO as "Order Number",
        t.INIVDT as "Invoice Date",
        t.INIVAM as "Inv Val",
        t.INIDAM as "Inv Dsc",
        t.ININSL as "Ord Val",
        t.INCONO as "Company Number",
        t.INCSNO as "Customer Number",
        t.INPONO as "Customer PO",
        t.INTMDS as "Terms Des" ,
        t.INORDT as "Order Date",
        t.INRQDT as "Request Date",
        t.INSHIN as "Shipping Inst",
        t.INWHSE as "Warehouse",
        t.INORVL as "OrderValue" ,
        t1.XNTRPN as "Trip#",
        t2."Sold to Name",
        t2."Sold to Address",
        t2."sold to CITY/STATE/ZIP",
        t2."Ship to Name",
        t2."Ship to Address",
        t2."Ship to CITY/STATE/ZIP",
        t2.SSSCTY,
        t2.SSSPCN,
        CASE
            WHEN t.INWHSE = 'C' THEN
                CASE
                    WHEN t.INSHIN IS NULL THEN 'NULL_INSHIN'
                    ELSE TRIM(CAST(t.INSHIN AS CHAR(50)))
                END
            WHEN t.INWHSE = '335' THEN
                CASE
                    WHEN t1.XNTRPN IS NULL THEN 'NULL_XNTRPN'
                    ELSE TRIM(CAST(t1.XNTRPN AS CHAR(50)))
                END
            ELSE 'Unknown'
        END AS ShippingIntr_Trips
    FROM AFILELIB.TSININ AS t
    left join trip as t1 on t.ININVR = t1.XNINVR and t.INORNO = t1.XNORNO
    left join ss as t2 on t.ININVR = t2.SSINVR and t.INORNO = t2.SSORNO
    WHERE t.INWHSE in ('C','335')
AND t.INIVDT >= TO_CHAR(CURRENT DATE - 3 DAYS, 'YYYYMMDD')

 

    """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'afi_query_{current_time}.csv'
    downloads_path = os.path.join(os.path.expanduser('~'), 'Downloads')
    file_path = os.path.join(downloads_path, file_name)

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

