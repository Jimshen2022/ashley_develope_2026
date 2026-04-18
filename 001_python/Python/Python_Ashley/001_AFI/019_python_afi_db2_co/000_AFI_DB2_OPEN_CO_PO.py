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

    # SQL查询 - 修复了转义序列问题
    query = """
-- File Path: D:\\Documents\\00-Query\\Project_Query\\Open order C and CNW_Query_version03.xlsb
-- Query Name: ASHTON OPEN ORDER QUERY FOR TRUDY
-- Created on: Oct 16, 2024, Version: 03
-- Modification History:
--   • Aug 06, 2025 – Added 'Ship Inst' column by Nguyen, Helen requirement

SELECT a1.HOUSE,a1.ORDNO,a1.SHINS as "Ship Inst", a1.ITMSQ,a1.ITNBR,a1.ITDSC,a1.ITCLS,a1.CCUSNO,a1.CSHPNO,a1.CUSNM,a1.CUSPO,
to_date(char(a1.TKNDAT),'yyyymmdd') Order_Taken_Date,to_date(char(a1.FRZDAT),'yyyymmdd') Original_Request_Date, to_date(char(a1.RQSDAT),'yyyymmdd') CRD,to_date(char(a1.RQIDT),'yyyymmdd') CPD, to_date(char(a1.MFIDT),'yyyymmdd')  LoadDate,
a1.ORDUSR,a1.COQTY,a1.QTYSH,a1.QTYBO,a1.OPEN_CO_QTY,a1.ALC,
a1.Product,x1.BDTRP#,x1.BDISEQ, x1.BDITQT as Trip_Qty,
x1.BDITCT,x1.BDITWT,x1.BDREF#,x1.BHCDAT,x1.BHCTIM,x1.BHRDAT,x1.BHLDAT,x1.BHLTIM
FROM
(
Select  t1.HOUSE,t1.ORDNO,t1.ITMSQ,t1.ITNBR,t1.ITDSC,t1.ITCLS, t1.CCUSNO,t3.CUSNM, T1.CSHPNO, T1.RQIDT,T1.MFIDT,T1.UNMSR,t4.CUSPO,t4.SHINS,
(CASE
    WHEN t1.ITCLS NOT LIKE 'Z%' THEN 'RP'
    WHEN SUBSTR(t1.ITNBR,1,4)='100-' THEN 'CG'
    WHEN SUBSTR(t1.ITNBR,1,1) in ('A','B','D','E','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
    ELSE 'UPH' END) as Product,t2.TKNDAT,t2.FRZDAT,t2.RQSDAT,t2.ORDUSR,
 t1.COQTY,t1.QTYSH,t1.QTYBO, T1.COQTY-T1.QTYSH AS OPEN_CO_QTY,
(CASE
    WHEN t1.IAFLG=0 THEN 'N'
    WHEN t1.IAFLG = 2 THEN 'Y'
    ELSE 'Check' END) AS ALC

FROM AFILELIB.CODATAN t1, AFILELIB.EXTORD t2,AFILELIB.ACUSMASJ t3, AFILELIB.COMAST t4
WHERE t2.XORDNO =t1.ORDNO AND t3.CUSNO = t1.CCUSNO AND t1.ORDNO=t4.ORDNO AND t1.house IN ('335','CNW','C')
AND t1.COQTY-t1.QTYSH<>0
) as a1

LEFT JOIN
(-- trip demand
SELECT  t1.BDTRP#,t1.BDORD#,t1.BDISEQ,t1.BDITM#,t1.BDITMD,t1.BDCUS#, t1.BDITQT,
t1.BDITCT,t1.BDITWT,t1.BDREF#,t1.BDCDAT,t1.BDCTIM,t2.BHTRPS,t2.BHCDAT,t2.BHCTIM,t2.BHRDAT,t2.BHLDAT,t2.BHLTIM
FROM DISTLIB.BTTRIPD t1, DISTLIB.BTTRIPH t2
WHERE t2.BHWHS# IN ('335','CNW','C') AND t2.BHLDAT BETWEEN 0 AND 29991231 AND t2.BHTRPS IN ('A','R','X') AND t1.BDTRP# = t2.BHTRP#
ORDER BY t1.BDTRP#,t1.BDISEQ,t1.BDITM#
) x1  ON a1.ORDNO||a1.ITMSQ||a1.ITNBR||a1.CCUSNO = x1.BDORD#||x1.BDISEQ||x1.BDITM#||x1.BDCUS#
ORDER BY a1.MFIDT,x1.BDTRP#,a1.ITNBR,x1.BDISEQ
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

        print("正在保存和格式化CSV文件...")
        save_file(df, file_path)

        print(f"CSV文件已成功保存到: {file_path}")

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == '__main__':
    main()